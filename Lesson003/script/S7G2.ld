/*
                  Linker File for S7G2 MCU
*/

/* Linker script to configure memory regions. */
MEMORY
{
  FLASH (rx)         : ORIGIN = 0x00000000, LENGTH = 0x0400000  /*   4M */
  RAM (rwx)          : ORIGIN = 0x1FFE0000, LENGTH = 0x00A0000  /* 640K */
  DATA_FLASH (rx)    : ORIGIN = 0x40100000, LENGTH = 0x0010000  /*  64K */
  QSPI_FLASH (rx)    : ORIGIN = 0x60000000, LENGTH = 0x4000000  /*  64M, Change in QSPI section below also */
  SDRAM (rwx)        : ORIGIN = 0x90000000, LENGTH = 0x2000000  /*  32M */
}

/* Library configurations */
GROUP(libgcc.a libc.a libm.a libnosys.a)

/* Linker script to place sections and symbol values. Should be used together
 * with other linker script that defines memory regions FLASH and RAM.
 * It references following symbols, which must be defined in code:
 *   Reset_Handler : Entry of reset handler
 *
 * It defines following symbols, which code can use without definition:
 *   __exidx_start
 *   __exidx_end
 *   __copy_table_start__
 *   __copy_table_end__
 *   __zero_table_start__
 *   __zero_table_end__
 *   __etext
 *   __data_start__
 *   __preinit_array_start
 *   __preinit_array_end
 *   __init_array_start
 *   __init_array_end
 *   __fini_array_start
 *   __fini_array_end
 *   __data_end__
 *   __bss_start__
 *   __bss_end__
 *   __end__
 *   end
 *   __HeapLimit
 *   __StackLimit
 *   __StackTop
 *   __stack
 *   __Vectors_End
 *   __Vectors_Size
 *   __qspi_flash_start__
 *   __qspi_flash_end__
 *   __qspi_flash_code_size__
 *   __qspi_region_max_size__
 *   __qspi_region_start_address__
 *   __qspi_region_end_address__
 */
ENTRY(Reset_Handler)

SECTIONS
{
	.text :
	{
		__ROM_Start = .;

        /* Even though the vector table is not 256 entries (1KB) long, we still allocate that much
         * space because ROM registers are at address 0x400 and there is very little space
         * in between. */
		KEEP(*(.vectors))
		__Vectors_End = .;
		__Vectors_Size = __Vectors_End - __Vectors;
		__end__ = .;

		/* ROM Registers start at address 0x00000400 */
		. = __ROM_Start + 0x400;
		KEEP(*(.rom_registers*))

		/* Reserving 0x100 bytes of space for ROM registers. */
		. = __ROM_Start + 0x500;

		*(.text*)

		KEEP(*(.init))
		KEEP(*(.fini))

		/* .ctors */
		*crtbegin.o(.ctors)
		*crtbegin?.o(.ctors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
		*(SORT(.ctors.*))
		*(.ctors)

		/* .dtors */
 		*crtbegin.o(.dtors)
 		*crtbegin?.o(.dtors)
 		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
 		*(SORT(.dtors.*))
 		*(.dtors)

		*(.rodata*)

		KEEP(*(.eh_frame*))

		__ROM_End = .;
	} > FLASH = 0xFF

	.ARM.extab :
	{
		*(.ARM.extab* .gnu.linkonce.armextab.*)
	} > FLASH

	__exidx_start = .;
	.ARM.exidx :
	{
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
	} > FLASH
	__exidx_end = .;

	/* To copy multiple ROM to RAM sections,
	 * uncomment .copy.table section and,
	 * define __STARTUP_COPY_MULTIPLE in startup_ARMCMx.S */
	/*
	.copy.table :
	{
		. = ALIGN(4);
		__copy_table_start__ = .;
		LONG (__etext)
		LONG (__data_start__)
		LONG (__data_end__ - __data_start__)
		LONG (__etext2)
		LONG (__data2_start__)
		LONG (__data2_end__ - __data2_start__)
		__copy_table_end__ = .;
	} > FLASH
	*/

	/* To clear multiple BSS sections,
	 * uncomment .zero.table section and,
	 * define __STARTUP_CLEAR_BSS_MULTIPLE in startup_ARMCMx.S */
	/*
	.zero.table :
	{
		. = ALIGN(4);
		__zero_table_start__ = .;
		LONG (__bss_start__)
		LONG (__bss_end__ - __bss_start__)
		LONG (__bss2_start__)
		LONG (__bss2_end__ - __bss2_start__)
		__zero_table_end__ = .;
	} > FLASH
	*/

	__etext = .;

	/* Initialized data section. */
	.data : AT (__etext)
	{
		__data_start__ = .;
		*(vtable)
		*(.data*)

		. = ALIGN(4);
		/* preinit data */
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP(*(.preinit_array))
		PROVIDE_HIDDEN (__preinit_array_end = .);

		. = ALIGN(4);
		/* init data */
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP(*(SORT(.init_array.*)))
		KEEP(*(.init_array))
		PROVIDE_HIDDEN (__init_array_end = .);


		. = ALIGN(4);
		/* finit data */
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP(*(SORT(.fini_array.*)))
		KEEP(*(.fini_array))
		PROVIDE_HIDDEN (__fini_array_end = .);

		KEEP(*(.jcr*))
		. = ALIGN(4);

		__Code_In_RAM_Start = .;

		KEEP(*(.code_in_ram*))
		__Code_In_RAM_End = .;

		/* All data end */
		__data_end__ = .;

	} > RAM

    /* QSPI_FLASH Retentive section */
	.qspi_retentive (NOLOAD):
    {
        __qspi_retentive_start__ = .;
        KEEP(*(.qspi_retentive*))
        __qspi_retentive_end__ = .;
    } > QSPI_FLASH
	__qspi_retentive_size__ = __qspi_retentive_end__ - __qspi_retentive_start__;

    /* QSPI_FLASH Non-retentive section */
    __qspi_flash_code_addr__ = __etext + (__data_end__ - __data_start__);
    .qspi_flash : AT (__qspi_flash_code_addr__)
    {
        __qspi_flash_start__ = .;
        KEEP(*(.qspi_flash*))
        __qspi_flash_end__ = .;
    } > QSPI_FLASH

    __qspi_flash_code_size__ = __qspi_flash_end__ - __qspi_flash_start__;
    __qspi_region_max_size__ = 0x4000000;   /* Must be the same as defined in MEMORY above */
    __qspi_region_start_address__ = __qspi_flash_start__;
    __qspi_region_end_address__ = __qspi_flash_start__ + __qspi_region_max_size__;

    .noinit (NOLOAD):
    {
		. = ALIGN(4);
        __noinit_start = .;
        KEEP(*(.noinit*))
        __noinit_end = .;
    } > RAM

	.bss :
	{
		. = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		__bss_end__ = .;
	} > RAM

	.heap (NOLOAD):
	{
		__HeapBase = .;
		__end__ = .;
		end = __end__;
		KEEP(*(.heap*))
		__HeapLimit = .;
	} > RAM

	/* Stacks are stored in this section. */
	.stack_dummy (NOLOAD):
	{
	    __StackLimit = .;
		KEEP(*(.stack*))
		__StackTop = .;
	} > RAM

	PROVIDE(__stack = __StackTop);

	/* This symbol represents the end of user allocated RAM. The RAM after this symbol can be used
	   at run time for things such as ThreadX memory pool allocations. */
	__RAM_segment_used_end__ = ALIGN(__StackTop , 4);

	/* Data flash. */
	.data_flash :
	{
		__Data_Flash_Start = .;
		KEEP(*(.data_flash*))
		__Data_Flash_End = .;
	} > DATA_FLASH

    /* SDRAM */
    .sdram (NOLOAD):
    {
        __SDRAM_Start = .;
        KEEP(*(.sdram*))
        KEEP(*(.frame*))
        __SDRAM_End = .;
    } > SDRAM
}
