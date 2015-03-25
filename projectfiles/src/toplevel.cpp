#include <jamaica.h>
#include <stdlib.h>
#include "toplevel.h"
#include <juniperoperations.h>

#define VERSION 21

jamaica_thread __juniper_thread;
int __juniper_args[ARGS_MAX];

//Memory interfaces
volatile int *__juniper_ram_master;
volatile char *__juniper_ram_master_char;
volatile short *__juniper_ram_master_short;
#ifdef JUNIPER_SUPPORT_FLOATS
volatile float *__juniper_ram_master_float;
#endif

int hls(int *slavea, int *slaveb, int *slavec, int *slaved) {

/*
 * Bundle the different memory interfaces together into the same AXI Master interface
 * This uses slave offset mode, which allows each interface to be separately offset.
 * This is not what we want, but HLS only supports AXI master bundling if offsetting
 * is also used.
 */
#pragma HLS INTERFACE m_axi port=__juniper_ram_master bundle=MAXI offset=slave
#pragma HLS INTERFACE m_axi port=__juniper_ram_master_char bundle=MAXI offset=slave
#pragma HLS INTERFACE m_axi port=__juniper_ram_master_short bundle=MAXI offset=slave
#ifdef JUNIPER_SUPPORT_FLOATS
#pragma HLS INTERFACE m_axi port=__juniper_ram_master_float bundle=MAXI offset=slave
#endif
/*
 * Place all control logic (and the offsets for the memory interfaces) on an AXI slave
 * interface.
 */
#pragma HLS INTERFACE s_axilite port=slavea bundle=AXILiteS register
#pragma HLS INTERFACE s_axilite port=slaveb bundle=AXILiteS register
#pragma HLS INTERFACE s_axilite port=slavec bundle=AXILiteS register
#pragma HLS INTERFACE s_axilite port=slaved bundle=AXILiteS register
#pragma HLS INTERFACE s_axilite port=return bundle=AXILiteS register

	//Set up dummy __juniper_thread struct
	create_jamaica_thread();

	switch(*slavea) {
	case OP_VERSION: return VERSION;

	/*
	 * Read memory location [slaveb]
	 * Because the memory interfaces are types, the address is interpreted as an
	 * index for the appropriate type, so the host should divide the raw addr by
	 * 4 to read ints, or 2 for shorts.
	 *
	 * For fabricating Jamaica references on the host the following is correct:
	 * val = JAMAICA_BLOCK_GET_DATA32((jamaica_ref) (0x80001000/4), 0);
	 * because jamaica_refs are integer-indexed pointers.
	 */
	case OP_PEEK: return __juniper_ram_master[*slaveb];
	case OP_PEEK_16: return __juniper_ram_master_short[*slaveb];
	case OP_PEEK_8: return __juniper_ram_master_char[*slaveb];
#ifdef JUNIPER_SUPPORT_FLOATS
	case OP_PEEK_F: return __juniper_ram_master_float[*slaveb];
#endif

	//Write slavec to memory[slaveb]
	case OP_POKE:
		__juniper_ram_master[*slaveb] = *slavec;
		return 0;
	case OP_POKE_16:
		__juniper_ram_master_short[*slaveb] = *slavec;
		return 0;
	case OP_POKE_8:
		__juniper_ram_master_char[*slaveb] = *slavec;
		return 0;
#ifdef JUNIPER_SUPPORT_FLOATS
	case OP_POKE_F:
		__juniper_ram_master_float[*slaveb] = *slavec;
		return 0;
#endif

	//Set argument[slaveb] to slavec
	case OP_WRITE_ARG:
		if(*slaveb >= 0 && *slaveb < ARGS_MAX) {
			__juniper_args[*slaveb] = *slavec;
		}
		return 0;

	//Call method ID slaveb
	case OP_CALL:
		int rv = __juniper_call(*slaveb);
		break;
	}

	return 0;
}

