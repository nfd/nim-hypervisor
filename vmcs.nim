#[ Set up VMCS.

We initialise the virtual CPU to plain old 16-bit mode, as if it had just been started.

]#
from strformat import `&`

import hypervisor

proc write_vmcs(vcpu: hv_vcpuid_t, field: uint32_t, value: uint64_t) =
  #echo &"write_vmcs {field:#X} {value:#X}"
  if hv_vmx_vcpu_write_vmcs(vcpu, field, value) != HV_SUCCESS:
    echo "write_vmcs failed"

proc read_vmcs(vcpu: hv_vcpuid_t, field: uint32_t): uint64_t =
  var val: uint64_t
  if hv_vmx_vcpu_read_vmcs(vcpu, field, addr(val)) != HV_SUCCESS:
    echo "read_vmcs failed"

  return val

template init_guest_segment_16bit(vcpu: hv_vcpuid_t, segment: untyped, rights: static int, limit: int=0xffff) =
  write_vmcs(vcpu, `"VMCS_GUEST_" segment`, 0)
  write_vmcs(vcpu, `"VMCS_GUEST_" segment "_BASE"`, 0)
  write_vmcs(vcpu, `"VMCS_GUEST_" segment "_LIMIT"`, limit)
  write_vmcs(vcpu, `"VMCS_GUEST_" segment "_AR"`, rights)

template null_dt(vcpu: hv_vcpuid_t, segment: untyped) =
  write_vmcs(vcpu, `"VMCS_GUEST_" segment "R_LIMIT"`, 0)
  write_vmcs(vcpu, `"VMCS_GUEST_" segment "R_BASE"`, 0)

proc set_vmcs_control_field(vcpu: hv_vcpuid_t, cap_field: uint32_t, ctrl_field: uint32_t, or_with: uint64_t) =
  var val: uint64_t
  if hv_vmx_read_capability(cap_field, addr(val)) != HV_SUCCESS:
    echo "read_cap failed"
    return

  # TODO: No idea why it's done this way.
  val = ((val and 0xffffffff'u64) or or_with) and (val shr 32)

  write_vmcs(vcpu, ctrl_field, val)

proc vmcs_init_16bit*(vcpu: hv_vcpuid_t): bool =
  # Set host controls, which determine what things cause a VM exit (i.e. control returns to us)
  # ... "pin-based controls" (concerning interrupts)
  set_vmcs_control_field(vcpu, HV_VMX_CAP_PINBASED, VMCS_CTRL_PIN_BASED, 0)
  # ... "processor-based controls" (concerning execution of various special instructions)
  set_vmcs_control_field(vcpu, HV_VMX_CAP_PROCBASED, VMCS_CTRL_CPU_BASED, CPU_BASED_HLT)  # HLT causes a VM exit
  set_vmcs_control_field(vcpu, HV_VMX_CAP_PROCBASED2, VMCS_CTRL_CPU_BASED2, 0)
  # ... VM entry controls, mostly concerning whether specific MSRs are loaded on VM entry.
  set_vmcs_control_field(vcpu, HV_VMX_CAP_ENTRY, VMCS_CTRL_VMENTRY_CONTROLS, 0)

  # Set exception bitmap: 32 bits where a 1 indicates a VM exit occurs on that exception.
  write_vmcs(vcpu, VMCS_CTRL_EXC_BITMAP, 0xffffffff'u32)  # all 1s = any exception triggers VM exit

  # Mask and shadow guest control registers: if a bit is set in the mask, then
  # that bit can't be changed in the control register and reading it always
  # returns the shadowed value. If a mask bit is not set then the guest can
  # read and modify the corresponding control register bit.
  # ... cr0: diable not-write-through and cache-disable.
  write_vmcs(vcpu, VMCS_CTRL_CR0_MASK, 0b0110_0000_0000_0000_0000_0000_0000_0000'u32)
  write_vmcs(vcpu, VMCS_CTRL_CR0_SHADOW, 0)
  # ... cr4: no protected bits.
  write_vmcs(vcpu, VMCS_CTRL_CR4_MASK, 0)
  write_vmcs(vcpu, VMCS_CTRL_CR4_SHADOW, 0)

  # Set segments to initial 16-bit states.
  # Note that, unintuitively, "accessed" must be set on all segments (regardless of processor mode). See IA32/64 SDM,
  # volume 3c, section 26.3.1.2, "Checks on Guest Segment Registers"
  init_guest_segment_16bit(vcpu, CS, VMCS_SEG_CODE or VMCS_SEG_NONSYSTEM or VMCS_SEG_PRESENT or VMCS_SEG_READABLE or VMCS_SEG_ACCESSED)
  init_guest_segment_16bit(vcpu, DS, VMCS_SEG_NONSYSTEM or VMCS_SEG_PRESENT or VMCS_SEG_WRITABLE or VMCS_SEG_ACCESSED)
  init_guest_segment_16bit(vcpu, ES, VMCS_SEG_NONSYSTEM or VMCS_SEG_PRESENT or VMCS_SEG_WRITABLE or VMCS_SEG_ACCESSED)
  init_guest_segment_16bit(vcpu, FS, VMCS_SEG_NONSYSTEM or VMCS_SEG_PRESENT or VMCS_SEG_WRITABLE or VMCS_SEG_ACCESSED)
  init_guest_segment_16bit(vcpu, GS, VMCS_SEG_NONSYSTEM or VMCS_SEG_PRESENT or VMCS_SEG_WRITABLE or VMCS_SEG_ACCESSED)
  init_guest_segment_16bit(vcpu, SS, VMCS_SEG_NONSYSTEM or VMCS_SEG_PRESENT or VMCS_SEG_WRITABLE or VMCS_SEG_ACCESSED)
  init_guest_segment_16bit(vcpu, LDTR, VMCS_SEG_UNUSABLE, limit=0)
  init_guest_segment_16bit(vcpu, TR, VMCS_SEG_PRESENT or VMCS_SEG_WRITABLE or VMCS_SEG_ACCESSED, limit=0)

  # No GDT or IDT in real mode
  null_dt(vcpu, GDT)
  null_dt(vcpu, IDT)

  # Guest control registers. CR0.NE and CR4.VMXE must be set to 1 here. See
  # IA32/64 SDM, volume 3c, section 23.8, "Restrictions on VMX operation"
  write_vmcs(vcpu, VMCS_GUEST_CR0, 0b0010_0000)  # NE: use internal x87 error reporting (must be set for VMX)
  write_vmcs(vcpu, VMCS_GUEST_CR3, 0)  # Paging-related info, unused in real mode
  write_vmcs(vcpu, VMCS_GUEST_CR4, 0x2000)  # Many extensions, all disabled except VMXE (must be set for VMX)

  return true

proc vmcs_get_exit_reason*(vcpu: hv_vcpuid_t): uint64 =
  return read_vmcs(vcpu, VMCS_RO_EXIT_REASON)

proc vmcs_read_irq_number*(vcpu: hv_vcpuid_t): uint8 =
  return cast[uint8](read_vmcs(vcpu, VMCS_RO_IDT_VECTOR_INFO) and 0xff)
