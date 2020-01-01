import streams
from strformat import `&`
from os import paramStr

import hypervisor
import vmcs

type
  HVInstance* = ref object of RootObj
    mem_size: uint
    mem: ptr uint8  # physical memory
    vcpu: hv_vcpuid_t

proc init(inst: HVInstance): bool =
  # Create a hypervisor context for this process
  if hv_vm_create(HV_VM_DEFAULT) != HV_SUCCESS:
    echo "Failed to create VM"
    return false

  # Allocate initial physical memory
  inst.mem_size = 16 * 1024 * 1024

  inst.mem = create(uint8, inst.mem_size)

  # Assign it to the VM
  if hv_vm_map(inst.mem, 0, inst.mem_size, HV_MEMORY_READ or HV_MEMORY_WRITE or HV_MEMORY_EXEC) != HV_SUCCESS:
    echo "Failed to map memory"
    return false

  # Create a virtual CPU
  if hv_vcpu_create(addr(inst.vcpu), HV_VCPU_DEFAULT) != HV_SUCCESS:
    echo "Couldn't create VCPU"
    return false

  # Initialise CPU as if it had just started.
  if not vmcs_init_16bit(inst.vcpu):
    return false

  return true

proc deinit(inst: HVInstance): bool =
  if hv_vcpu_destroy(inst.vcpu) != HV_SUCCESS:
    echo "Failed to destroy CPU"
    return false

  if hv_vm_unmap(0, inst.mem_size) != HV_SUCCESS:
    echo "Failed to unmap memory"
    return false

  dealloc(inst.mem)
  inst.mem = nil

  discard hv_vm_destroy()

  return true

proc load(inst: HVInstance, filename: string, start_address: int) =
  const
    chunk_size = 1024 * 128

  var
    s = newFileStream(filename, fmRead)
    pos: int = start_address

  while not s.atEnd():
    var amt_read = s.readData(cast[ptr uint8](cast[int](inst.mem) + pos), chunk_size)
    assert amt_read > 0
    pos += amt_read

proc write_reg(inst: HVInstance, reg: hv_x86_reg_t, value: uint64_t) =
  if hv_vcpu_write_register(inst.vcpu, reg, value) != HV_SUCCESS:
    echo "write_register failed"

proc start(inst: HVInstance, start_address: uint64) =
  # Prepare to start execution at a given address.
  inst.write_reg(HV_X86_RIP, start_address)
  inst.write_reg(HV_X86_RFLAGS, 2)  # TODO
  inst.write_reg(HV_X86_RSP, 0)

proc run(inst: HVInstance) =
  while true:
    if hv_vcpu_run(inst.vcpu) != HV_SUCCESS:
      echo "vcpu_fun failed"
      break

    var exit_reason = vmcs_get_exit_reason(inst.vcpu)
    if (exit_reason and 0x80000000'u64) != 0:
      echo "VM Entry failure: ", exit_reason and 0xffff
      break

    case (uint16)(exit_reason and 0xffff)
    of VMX_REASON_EXC_NMI:
      echo "Exception ", vmcs_read_irq_number(inst.vcpu)
      break
    of VMX_REASON_EPT_VIOLATION:
      # Cache miss (or MMIO -- TODO)
      discard
    else:
      echo &"Unknown exit reason {exit_reason}"
      break

proc main() =
  var instance = HVInstance()

  if not instance.init():
    return

  instance.load(paramStr(1), 0)
  instance.start(0x100)
  instance.run()

  discard instance.deinit()

  echo "Hypervisor started and stopped. :D"

main()
