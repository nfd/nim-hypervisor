#[

Portions derived from a c2nim pass.

]#

{.passL: "-framework Hypervisor".}

type
  uint64_t* = culonglong
  hv_vm_options_t* = uint64_t
  cbool* = cuint
  uint32_t* = cuint
  hv_uvaddr_t* = pointer
  hv_return_t* = cint
  hv_gpaddr_t* = uint64_t
  hv_memory_flags_t* = uint64_t
  hv_vcpuid_t* = cuint
  hv_vcpu_options_t* = uint64_t
  hv_x86_reg_t* = enum
    HV_X86_RIP, HV_X86_RFLAGS, HV_X86_RAX, HV_X86_RCX, HV_X86_RDX, HV_X86_RBX,
    HV_X86_RSI, HV_X86_RDI, HV_X86_RSP, HV_X86_RBP, HV_X86_R8, HV_X86_R9, HV_X86_R10,
    HV_X86_R11, HV_X86_R12, HV_X86_R13, HV_X86_R14, HV_X86_R15, HV_X86_CS, HV_X86_SS,
    HV_X86_DS, HV_X86_ES, HV_X86_FS, HV_X86_GS, HV_X86_IDT_BASE, HV_X86_IDT_LIMIT,
    HV_X86_GDT_BASE, HV_X86_GDT_LIMIT, HV_X86_LDTR, HV_X86_LDT_BASE,
    HV_X86_LDT_LIMIT, HV_X86_LDT_AR, HV_X86_TR, HV_X86_TSS_BASE, HV_X86_TSS_LIMIT,
    HV_X86_TSS_AR, HV_X86_CR0, HV_X86_CR1, HV_X86_CR2, HV_X86_CR3, HV_X86_CR4,
    HV_X86_DR0, HV_X86_DR1, HV_X86_DR2, HV_X86_DR3, HV_X86_DR4, HV_X86_DR5,
    HV_X86_DR6, HV_X86_DR7, HV_X86_TPR, HV_X86_XCR0, HV_X86_REGISTERS_MAX

# hv_vm_options_t (VM options)
const
  HV_VM_DEFAULT* = (0 shl 0)
  HV_VM_SPECIFY_MITIGATIONS* = (1 shl 0)
  HV_VM_MITIGATION_A_ENABLE* = (1 shl 1)
  HV_VM_MITIGATION_B_ENABLE* = (1 shl 2)
  HV_VM_MITIGATION_C_ENABLE* = (1 shl 3)
  HV_VM_MITIGATION_D_ENABLE* = (1 shl 4)

# hv_return_t (return values). These are stored in a pretty crazy way in hv.h and simplified here.
const
  HV_SUCCESS* = 0
  HV_ERROR* = 0xfae94001
  HV_BUSY* = 0xfae94002
  HV_BAD_ARGUMENT* = 0xfae94003
  HV_NO_RESOURCES* = 0xfae94005
  HV_NO_DEVICE* = 0xfae94006
  HV_UNSUPPORTED* = 0xfae9400f

# hv_memory_flags_t
const
  HV_MEMORY_READ* = (1 shl 0)
  HV_MEMORY_WRITE* = (1 shl 1)
  HV_MEMORY_EXEC* = (1 shl 2)

# hv_vmx_capability_t
const
  HV_VMX_CAP_PINBASED* = 0          # pin-based VMX capabilities
  HV_VMX_CAP_PROCBASED* = 1         # primary proc.-based VMX capabilities
  HV_VMX_CAP_PROCBASED2* = 2        # second. proc.-based VMX capabilities
  HV_VMX_CAP_ENTRY* = 3             # VM-entry VMX capabilities
  HV_VMX_CAP_EXIT* = 4              # VM-exit VMX capabilities
  HV_VMX_CAP_PREEMPTION_TIMER* = 32 # VMX preemption timer frequency

# hv_vcpu_options_t
const
  HV_VCPU_DEFAULT* = 0

proc hv_vm_create*(flags: hv_vm_options_t): hv_return_t {.importc: "hv_vm_create".}

proc hv_vm_destroy*(): hv_return_t {.importc: "hv_vm_destroy".}

proc hv_vm_map*(uva: hv_uvaddr_t; gpa: hv_gpaddr_t; size: csize_t; flags: hv_memory_flags_t): hv_return_t {.importc: "hv_vm_map".}

proc hv_vm_unmap*(gpa: hv_gpaddr_t; size: csize_t): hv_return_t {.importc: "hv_vm_unmap".}

proc hv_vm_protect*(gpa: hv_gpaddr_t; size: csize_t; flags: hv_memory_flags_t): hv_return_t {.importc: "hv_vm_protect".}

proc hv_vm_sync_tsc*(tsc: uint64_t): hv_return_t {.importc: "hv_vm_sync_tsc".}

proc hv_vcpu_create*(vcpu: ptr hv_vcpuid_t; flags: hv_vcpu_options_t): hv_return_t {.importc: "hv_vcpu_create".}

proc hv_vcpu_destroy*(vcpu: hv_vcpuid_t): hv_return_t {.importc: "hv_vcpu_destroy".}

proc hv_vcpu_read_register*(vcpu: hv_vcpuid_t; reg: hv_x86_reg_t; value: ptr uint64_t): hv_return_t {.importc: "hv_vcpu_read_register".}

proc hv_vcpu_write_register*(vcpu: hv_vcpuid_t; reg: hv_x86_reg_t; value: uint64_t): hv_return_t {.importc: "hv_vcpu_write_register".}

proc hv_vcpu_read_fpstate*(vcpu: hv_vcpuid_t; buffer: pointer; size: csize_t): hv_return_t {.importc: "hv_vcpu_read_fpstate".}

proc hv_vcpu_write_fpstate*(vcpu: hv_vcpuid_t; buffer: pointer; size: csize_t): hv_return_t {.importc: "hv_vcpu_write_fpstate".}

proc hv_vcpu_enable_native_msr*(vcpu: hv_vcpuid_t; msr: uint32_t; enable: cbool): hv_return_t {.importc: "hv_vcpu_enable_native_msr".}

proc hv_vcpu_read_msr*(vcpu: hv_vcpuid_t; msr: uint32_t; value: ptr uint64_t): hv_return_t {.importc: "hv_vcpu_read_msr".}

proc hv_vcpu_write_msr*(vcpu: hv_vcpuid_t; msr: uint32_t; value: uint64_t): hv_return_t {.importc: "hv_vcpu_write_msr".}

proc hv_vcpu_flush*(vcpu: hv_vcpuid_t): hv_return_t {.importc: "hv_vcpu_flush".}

proc hv_vcpu_invalidate_tlb*(vcpu: hv_vcpuid_t): hv_return_t {.importc: "hv_vcpu_invalidate_tlb".}

proc hv_vcpu_run*(vcpu: hv_vcpuid_t): hv_return_t {.importc: "hv_vcpu_run".}

proc hv_vcpu_interrupt*(vcpus: ptr hv_vcpuid_t; vcpu_count: cuint): hv_return_t {.importc: "hv_vcpu_interrupt".}

proc hv_vcpu_get_exec_time*(vcpu: hv_vcpuid_t; time: ptr uint64_t): hv_return_t {.importc: "hv_vcpu_get_exec_time".}

# From hv_vmx.h
proc hv_vmx_vcpu_read_vmcs*(vcpu: hv_vcpuid_t; field: uint32_t; value: ptr uint64_t): hv_return_t {.importc: "hv_vmx_vcpu_read_vmcs" .}

proc hv_vmx_vcpu_write_vmcs*(vcpu: hv_vcpuid_t; field: uint32_t; value: uint64_t): hv_return_t {.importc: "hv_vmx_vcpu_write_vmcs" .}

proc hv_vmx_read_capability*(field: uint32_t, value: ptr uint64_t): hv_return_t {.importc: "hv_vmx_read_capability" .}

proc hv_vmx_vcpu_set_apic_address*(cpu: hv_vcpuid_t, gpa: hv_gpaddr_t): hv_return_t {.importc: "hv_vmx_vcpu_set_apic_address" .}

# from hv_arch_vmx.h
const
  VMCS_VPID*               = 0x00000000
  VMCS_CTRL_POSTED_INT_N_VECTOR*     = 0x00000002
  VMCS_CTRL_EPTP_INDEX*         = 0x00000004
  VMCS_GUEST_ES*             = 0x00000800
  VMCS_GUEST_CS*             = 0x00000802
  VMCS_GUEST_SS*             = 0x00000804
  VMCS_GUEST_DS*             = 0x00000806
  VMCS_GUEST_FS*             = 0x00000808
  VMCS_GUEST_GS*             = 0x0000080a
  VMCS_GUEST_LDTR*             = 0x0000080c
  VMCS_GUEST_TR*             = 0x0000080e
  VMCS_GUEST_INT_STATUS*         = 0x00000810
  VMCS_HOST_ES*             = 0x00000c00
  VMCS_HOST_CS*             = 0x00000c02
  VMCS_HOST_SS*             = 0x00000c04
  VMCS_HOST_DS*             = 0x00000c06
  VMCS_HOST_FS*             = 0x00000c08
  VMCS_HOST_GS*             = 0x00000c0a
  VMCS_HOST_TR*             = 0x00000c0c
  VMCS_CTRL_IO_BITMAP_A*         = 0x00002000
  VMCS_CTRL_IO_BITMAP_B*         = 0x00002002
  VMCS_CTRL_MSR_BITMAPS*         = 0x00002004
  VMCS_CTRL_VMEXIT_MSR_STORE_ADDR*     = 0x00002006
  VMCS_CTRL_VMEXIT_MSR_LOAD_ADDR*     = 0x00002008
  VMCS_CTRL_VMENTRY_MSR_LOAD_ADDR*     = 0x0000200a
  VMCS_CTRL_EXECUTIVE_VMCS_PTR*     = 0x0000200c
  VMCS_CTRL_TSC_OFFSET*         = 0x00002010
  VMCS_CTRL_VIRTUAL_APIC*         = 0x00002012
  VMCS_CTRL_APIC_ACCESS*         = 0x00002014
  VMCS_CTRL_POSTED_INT_DESC_ADDR*     = 0x00002016
  VMCS_CTRL_VMFUNC_CTRL*         = 0x00002018
  VMCS_CTRL_EPTP*             = 0x0000201a
  VMCS_CTRL_EOI_EXIT_BITMAP_0*       = 0x0000201c
  VMCS_CTRL_EOI_EXIT_BITMAP_1*       = 0x0000201e
  VMCS_CTRL_EOI_EXIT_BITMAP_2*       = 0x00002020
  VMCS_CTRL_EOI_EXIT_BITMAP_3*       = 0x00002022
  VMCS_CTRL_EPTP_LIST_ADDR*       = 0x00002024
  VMCS_CTRL_VMREAD_BITMAP_ADDR*     = 0x00002026
  VMCS_CTRL_VMWRITE_BITMAP_ADDR*     = 0x00002028
  VMCS_CTRL_VIRT_EXC_INFO_ADDR*     = 0x0000202a
  VMCS_CTRL_XSS_EXITING_BITMAP*     = 0x0000202c
  VMCS_GUEST_PHYSICAL_ADDRESS*       = 0x00002400
  VMCS_GUEST_LINK_POINTER*         = 0x00002800
  VMCS_GUEST_IA32_DEBUGCTL*       = 0x00002802
  VMCS_GUEST_IA32_PAT*           = 0x00002804
  VMCS_GUEST_IA32_EFER*         = 0x00002806
  VMCS_GUEST_IA32_PERF_GLOBAL_CTRL*   = 0x00002808
  VMCS_GUEST_PDPTE0*           = 0x0000280a
  VMCS_GUEST_PDPTE1*           = 0x0000280c
  VMCS_GUEST_PDPTE2*           = 0x0000280e
  VMCS_GUEST_PDPTE3*           = 0x00002810
  VMCS_HOST_IA32_PAT*           = 0x00002c00
  VMCS_HOST_IA32_EFER*           = 0x00002c02
  VMCS_HOST_IA32_PERF_GLOBAL_CTRL*     = 0x00002c04
  VMCS_CTRL_PIN_BASED*           = 0x00004000
  VMCS_CTRL_CPU_BASED*           = 0x00004002
  VMCS_CTRL_EXC_BITMAP*         = 0x00004004
  VMCS_CTRL_PF_ERROR_MASK*         = 0x00004006
  VMCS_CTRL_PF_ERROR_MATCH*       = 0x00004008
  VMCS_CTRL_CR3_COUNT*           = 0x0000400a
  VMCS_CTRL_VMEXIT_CONTROLS*       = 0x0000400c
  VMCS_CTRL_VMEXIT_MSR_STORE_COUNT*   = 0x0000400e
  VMCS_CTRL_VMEXIT_MSR_LOAD_COUNT*     = 0x00004010
  VMCS_CTRL_VMENTRY_CONTROLS*       = 0x00004012
  VMCS_CTRL_VMENTRY_MSR_LOAD_COUNT*   = 0x00004014
  VMCS_CTRL_VMENTRY_IRQ_INFO*       = 0x00004016
  VMCS_CTRL_VMENTRY_EXC_ERROR*       = 0x00004018
  VMCS_CTRL_VMENTRY_INSTR_LEN*       = 0x0000401a
  VMCS_CTRL_TPR_THRESHOLD*         = 0x0000401c
  VMCS_CTRL_CPU_BASED2*         = 0x0000401e
  VMCS_CTRL_PLE_GAP*           = 0x00004020
  VMCS_CTRL_PLE_WINDOW*         = 0x00004022
  VMCS_RO_INSTR_ERROR*           = 0x00004400
  VMCS_RO_EXIT_REASON*           = 0x00004402
  VMCS_RO_VMEXIT_IRQ_INFO*         = 0x00004404
  VMCS_RO_VMEXIT_IRQ_ERROR*       = 0x00004406
  VMCS_RO_IDT_VECTOR_INFO*         = 0x00004408
  VMCS_RO_IDT_VECTOR_ERROR*       = 0x0000440a
  VMCS_RO_VMEXIT_INSTR_LEN*       = 0x0000440c
  VMCS_RO_VMX_INSTR_INFO*         = 0x0000440e
  VMCS_GUEST_ES_LIMIT*           = 0x00004800
  VMCS_GUEST_CS_LIMIT*           = 0x00004802
  VMCS_GUEST_SS_LIMIT*           = 0x00004804
  VMCS_GUEST_DS_LIMIT*           = 0x00004806
  VMCS_GUEST_FS_LIMIT*           = 0x00004808
  VMCS_GUEST_GS_LIMIT*           = 0x0000480a
  VMCS_GUEST_LDTR_LIMIT*         = 0x0000480c
  VMCS_GUEST_TR_LIMIT*           = 0x0000480e
  VMCS_GUEST_GDTR_LIMIT*         = 0x00004810
  VMCS_GUEST_IDTR_LIMIT*         = 0x00004812
  VMCS_GUEST_ES_AR*           = 0x00004814
  VMCS_GUEST_CS_AR*           = 0x00004816
  VMCS_GUEST_SS_AR*           = 0x00004818
  VMCS_GUEST_DS_AR*           = 0x0000481a
  VMCS_GUEST_FS_AR*           = 0x0000481c
  VMCS_GUEST_GS_AR*           = 0x0000481e
  VMCS_GUEST_LDTR_AR*           = 0x00004820
  VMCS_GUEST_TR_AR*           = 0x00004822
  VMCS_GUEST_IGNORE_IRQ*         = 0x00004824
  VMCS_GUEST_ACTIVITY_STATE*       = 0x00004826
  VMCS_GUEST_SMBASE*           = 0x00004828
  VMCS_GUEST_IA32_SYSENTER_CS*       = 0x0000482a
  VMCS_GUEST_VMX_TIMER_VALUE*       = 0x0000482e
  VMCS_HOST_IA32_SYSENTER_CS*       = 0x00004c00
  VMCS_CTRL_CR0_MASK*           = 0x00006000
  VMCS_CTRL_CR4_MASK*           = 0x00006002
  VMCS_CTRL_CR0_SHADOW*         = 0x00006004
  VMCS_CTRL_CR4_SHADOW*         = 0x00006006
  VMCS_CTRL_CR3_VALUE0*         = 0x00006008
  VMCS_CTRL_CR3_VALUE1*         = 0x0000600a
  VMCS_CTRL_CR3_VALUE2*         = 0x0000600c
  VMCS_CTRL_CR3_VALUE3*         = 0x0000600e
  VMCS_RO_EXIT_QUALIFIC*         = 0x00006400
  VMCS_RO_IO_RCX*             = 0x00006402
  VMCS_RO_IO_RSI*             = 0x00006404
  VMCS_RO_IO_RDI*             = 0x00006406
  VMCS_RO_IO_RIP*             = 0x00006408
  VMCS_RO_GUEST_LIN_ADDR*         = 0x0000640a
  VMCS_GUEST_CR0*             = 0x00006800
  VMCS_GUEST_CR3*             = 0x00006802
  VMCS_GUEST_CR4*             = 0x00006804
  VMCS_GUEST_ES_BASE*           = 0x00006806
  VMCS_GUEST_CS_BASE*           = 0x00006808
  VMCS_GUEST_SS_BASE*           = 0x0000680a
  VMCS_GUEST_DS_BASE*           = 0x0000680c
  VMCS_GUEST_FS_BASE*           = 0x0000680e
  VMCS_GUEST_GS_BASE*           = 0x00006810
  VMCS_GUEST_LDTR_BASE*         = 0x00006812
  VMCS_GUEST_TR_BASE*           = 0x00006814
  VMCS_GUEST_GDTR_BASE*         = 0x00006816
  VMCS_GUEST_IDTR_BASE*         = 0x00006818
  VMCS_GUEST_DR7*             = 0x0000681a
  VMCS_GUEST_RSP*             = 0x0000681c
  VMCS_GUEST_RIP*             = 0x0000681e
  VMCS_GUEST_RFLAGS*           = 0x00006820
  VMCS_GUEST_DEBUG_EXC*         = 0x00006822
  VMCS_GUEST_SYSENTER_ESP*         = 0x00006824
  VMCS_GUEST_SYSENTER_EIP*         = 0x00006826
  VMCS_HOST_CR0*             = 0x00006c00
  VMCS_HOST_CR3*             = 0x00006c02
  VMCS_HOST_CR4*             = 0x00006c04
  VMCS_HOST_FS_BASE*           = 0x00006c06
  VMCS_HOST_GS_BASE*           = 0x00006c08
  VMCS_HOST_TR_BASE*           = 0x00006c0a
  VMCS_HOST_GDTR_BASE*           = 0x00006c0c
  VMCS_HOST_IDTR_BASE*           = 0x00006c0e
  VMCS_HOST_IA32_SYSENTER_ESP*       = 0x00006c10
  VMCS_HOST_IA32_SYSENTER_EIP*       = 0x00006c12
  VMCS_HOST_RSP*             = 0x00006c14
  VMCS_HOST_RIP*             = 0x00006c16
  VMCS_MAX*              = 0x00006c18

const
  VMX_BASIC_TRUE_CTLS* = 1 shl 55

const
  PIN_BASED_INTR*            = 1 shl 0
  PIN_BASED_NMI*            = 1 shl 3
  PIN_BASED_VIRTUAL_NMI*        = 1 shl 5
  PIN_BASED_PREEMPTION_TIMER*      = 1 shl 6
  PIN_BASED_POSTED_INTR*        = 1 shl 7
  CPU_BASED_IRQ_WND*          = 1 shl 2
  CPU_BASED_TSC_OFFSET*        = 1 shl 3
  CPU_BASED_HLT*            = 1 shl 7
  CPU_BASED_INVLPG*          = 1 shl 9
  CPU_BASED_MWAIT*            = 1 shl 10
  CPU_BASED_RDPMC*            = 1 shl 11
  CPU_BASED_RDTSC*            = 1 shl 12
  CPU_BASED_CR3_LOAD*          = 1 shl 15
  CPU_BASED_CR3_STORE*          = 1 shl 16
  CPU_BASED_CR8_LOAD*          = 1 shl 19
  CPU_BASED_CR8_STORE*          = 1 shl 20
  CPU_BASED_TPR_SHADOW*        = 1 shl 21
  CPU_BASED_VIRTUAL_NMI_WND*      = 1 shl 22
  CPU_BASED_MOV_DR*          = 1 shl 23
  CPU_BASED_UNCOND_IO*          = 1 shl 24
  CPU_BASED_IO_BITMAPS*        = 1 shl 25
  CPU_BASED_MTF*            = 1 shl 27
  CPU_BASED_MSR_BITMAPS*        = 1 shl 28
  CPU_BASED_MONITOR*          = 1 shl 29
  CPU_BASED_PAUSE*            = 1 shl 30
  CPU_BASED_SECONDARY_CTLS*      = 1 shl 31
  CPU_BASED2_VIRTUAL_APIC*        = 1 shl 0
  CPU_BASED2_EPT*            = 1 shl 1
  CPU_BASED2_DESC_TABLE*        = 1 shl 2
  CPU_BASED2_RDTSCP*          = 1 shl 3
  CPU_BASED2_X2APIC*          = 1 shl 4
  CPU_BASED2_VPID*            = 1 shl 5
  CPU_BASED2_WBINVD*          = 1 shl 6
  CPU_BASED2_UNRESTRICTED*        = 1 shl 7
  CPU_BASED2_APIC_REG_VIRT*      = 1 shl 8
  CPU_BASED2_VIRT_INTR_DELIVERY*    = 1 shl 9
  CPU_BASED2_PAUSE_LOOP*        = 1 shl 10
  CPU_BASED2_RDRAND*          = 1 shl 11
  CPU_BASED2_INVPCID*          = 1 shl 12
  CPU_BASED2_VMFUNC*          = 1 shl 13
  CPU_BASED2_VMCS_SHADOW*        = 1 shl 14
  CPU_BASED2_RDSEED*          = 1 shl 16
  CPU_BASED2_EPT_VE*          = 1 shl 18
  CPU_BASED2_XSAVES_XRSTORS*      = 1 shl 20
  VMX_EPT_VPID_SUPPORT_AD*        = 1 shl 21
  VMX_EPT_VPID_SUPPORT_EXONLY*      = 1 shl 0
  VMEXIT_SAVE_DBG_CONTROLS*      = 1 shl 2
  VMEXIT_HOST_IA32E*          = 1 shl 9
  VMEXIT_LOAD_IA32_PERF_GLOBAL_CTRL*  = 1 shl 12
  VMEXIT_ACK_INTR*            = 1 shl 15
  VMEXIT_SAVE_IA32_PAT*        = 1 shl 18
  VMEXIT_LOAD_IA32_PAT*        = 1 shl 19
  VMEXIT_SAVE_EFER*          = 1 shl 20
  VMEXIT_LOAD_EFER*          = 1 shl 21
  VMEXIT_SAVE_VMX_TIMER*        = 1 shl 22
  VMENTRY_LOAD_DBG_CONTROLS*      = 1 shl 2
  VMENTRY_GUEST_IA32E*          = 1 shl 9
  VMENTRY_SMM*              = 1 shl 10
  VMENTRY_DEACTIVATE_DUAL_MONITOR*    = 1 shl 11
  VMENTRY_LOAD_IA32_PERF_GLOBAL_CTRL*  = 1 shl 13
  VMENTRY_LOAD_IA32_PAT*        = 1 shl 14
  VMENTRY_LOAD_EFER*          = 1 shl 1

# VMCS exit reasons
const
  VMX_REASON_EXC_NMI*          = 0
  VMX_REASON_IRQ*            = 1
  VMX_REASON_TRIPLE_FAULT*        = 2
  VMX_REASON_INIT*            = 3
  VMX_REASON_SIPI*            = 4
  VMX_REASON_IO_SMI*          = 5
  VMX_REASON_OTHER_SMI*        = 6
  VMX_REASON_IRQ_WND*          = 7
  VMX_REASON_VIRTUAL_NMI_WND*      = 8
  VMX_REASON_TASK*            = 9
  VMX_REASON_CPUID*          = 10
  VMX_REASON_GETSEC*          = 11
  VMX_REASON_HLT*            = 12
  VMX_REASON_INVD*            = 13
  VMX_REASON_INVLPG*          = 14
  VMX_REASON_RDPMC*          = 15
  VMX_REASON_RDTSC*          = 16
  VMX_REASON_RSM*            = 17
  VMX_REASON_VMCALL*          = 18
  VMX_REASON_VMCLEAR*          = 19
  VMX_REASON_VMLAUNCH*          = 20
  VMX_REASON_VMPTRLD*          = 21
  VMX_REASON_VMPTRST*          = 22
  VMX_REASON_VMREAD*          = 23
  VMX_REASON_VMRESUME*          = 24
  VMX_REASON_VMWRITE*          = 25
  VMX_REASON_VMOFF*          = 26
  VMX_REASON_VMON*            = 27
  VMX_REASON_MOV_CR*          = 28
  VMX_REASON_MOV_DR*          = 29
  VMX_REASON_IO*            = 30
  VMX_REASON_RDMSR*          = 31
  VMX_REASON_WRMSR*          = 32
  VMX_REASON_VMENTRY_GUEST*      = 33   # invalid guest state
  VMX_REASON_VMENTRY_MSR*        = 34
  VMX_REASON_MWAIT*          = 36
  VMX_REASON_MTF*            = 37
  VMX_REASON_MONITOR*          = 39
  VMX_REASON_PAUSE*          = 40
  VMX_REASON_VMENTRY_MC*        = 41
  VMX_REASON_TPR_THRESHOLD*      = 43
  VMX_REASON_APIC_ACCESS*        = 44
  VMX_REASON_VIRTUALIZED_EOI*      = 45
  VMX_REASON_GDTR_IDTR*        = 46
  VMX_REASON_LDTR_TR*          = 47
  VMX_REASON_EPT_VIOLATION*      = 48
  VMX_REASON_EPT_MISCONFIG*      = 49
  VMX_REASON_EPT_INVEPT*        = 50
  VMX_REASON_RDTSCP*          = 51
  VMX_REASON_VMX_TIMER_EXPIRED*    = 52
  VMX_REASON_INVVPID*          = 53
  VMX_REASON_WBINVD*          = 54
  VMX_REASON_XSETBV*          = 55
  VMX_REASON_APIC_WRITE*        = 56
  VMX_REASON_RDRAND*          = 57
  VMX_REASON_INVPCID*          = 58
  VMX_REASON_VMFUNC*          = 59
  VMX_REASON_RDSEED*          = 61
  VMX_REASON_XSAVES*          = 63
  VMX_REASON_XRSTORS*          = 64

const
  IRQ_INFO_EXT_IRQ* = 0
  IRQ_INFO_NMI* = 2 shl 8
  IRQ_INFO_HARD_EXC* = 3 shl 8
  IRQ_INFO_SOFT_IRQ* = 4 shl 8
  IRQ_INFO_PRIV_SOFT_EXC* = 5 shl 8
  IRQ_INFO_SOFT_EXC* = 6 shl 8
  IRQ_INFO_ERROR_VALID* = 1 shl 11
  IRQ_INFO_VALID* = 1 shl 31

# Not official names -- used to set VMCS segment access rights
const
  VMCS_SEG_UNUSABLE* = 1 shl 16
  VMCS_SEG_PRESENT* = 1 shl 7
  VMCS_SEG_NONSYSTEM* = 1 shl 4
  VMCS_SEG_CODE* = 1 shl 3
  VMCS_SEG_CONFORMING* = 1 shl 2  # valid if VMCS_SEG_CODE
  VMCS_SEG_EXPAND_DOWN* = 1 shl 2  # valid if !VMCS_SEG_CODE
  VMCS_SEG_READABLE* = 1 shl 1  # valid if VMCS_SEG_CODE
  VMCS_SEG_WRITABLE* = 1 shl 1  # valid if !VMCS_SEG_CODE
  VMCS_SEG_ACCESSED* = 1 shl 0  # Set by hardware


