
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdint.h>
#include "vm.h"

void *AX_Memory_Map(Core *core,uint64_t offset)
{
    void *address = NULL;
    uint64_t max = 0;

    if(offset&MEMORY_MAP_WRAM_BEGIN)
    {
        address = core->mmap.wram;
        max = core->mmap.nwram-1; //Max 2 Gio
    }
    else if(offset&MEMORY_MAP_VRAM_BEGIN)
    {
		address = core->mmap.vram;
		max = (core->mmap.nvram-1); //Max 1 Gio
	}
	else if(offset&MEMORY_MAP_SRAM_BEGIN)
	{
		address = core->mmap.spmram;
		max = (core->mmap.nspmram-1); //Max 512 Mio
	}
	else if(offset&MEMORY_MAP_SPM2_BEGIN)
	{
		address = core->mmap.spm2;
		max = (core->mmap.nspm2-1); //Max 256 Mio
	}
	else if(offset&MEMORY_MAP_SPMT_BEGIN)
	{
		address = core->mmap.spmt;
		max = (core->mmap.nspmt-1); //Max 128 Mio
	}
	else if(offset&MEMORY_MAP_ROM_BEGIN)
	{
		address = core->mmap.rom;
		max = (core->mmap.nrom-1); //Max 64 Mio
	}
	else if(offset&MEMORY_MAP_IO_BEGIN)
	{
		address = core->mmap.io;
		max = 0x7FFFFF; //Max 8 Mio (miroir 32 Mio)
	}
	else //SPM
	{
		address = core->spm;
		max = 0x7FFF; //Max 32 Kio
	}

	offset &= max;

    return address+offset;

}
int AX_load_prog(char *name,MMAP *mmap)
{
	FILE *file = fopen(name,"rb");
	if(file == NULL)
		return 1;


	fseek(file, 0, SEEK_END);
	int psize = ftell(file);

	fseek(file, 0, SEEK_SET);
	uint8_t *rom = malloc(psize);

	fread(rom,1,psize,file);
	fclose(file);

	mmap->rom = rom;
	mmap->nrom = psize;

	return 0;
}

void AX_boot_rom(Core *core,uint8_t* rom,int n)
{
	memcpy(core->wram,rom,n);
}


void AX_init_mem(Processor *processor,int nwram,int nvram,int nsram,int nspmt,int nspm2)
{
	nwram = 0x100000*nwram;  // nwram * MiB
	nvram = 0x100000*nvram;  // nvram * MiB
	nsram = 0x100000*nsram; // nsram * MiB

	nspmt = 0x400*nspmt; // nspmt * KiB
	nspm2 = 0x400*nspm2; // nspm2 * KiB

	processor->mmap.nwram = nwram;
	processor->mmap.nvram = nvram;
	processor->mmap.nspmram = nsram;

	processor->mmap.nspmt = nspmt;
	processor->mmap.nspm2 = nspm2;
}


int AX_init_proc(Processor *processor)
{
	processor->icore = 0;
	processor->ncore = 1;
	processor->mode = 0;

	return 0;
}

int AX_init_proc_mem(Processor *processor)
{
	processor->mmap.wram = malloc(processor->mmap.nwram);
	processor->mmap.vram = malloc(processor->mmap.nvram);
	processor->mmap.spmram = malloc(processor->mmap.nspmram);

	processor->mmap.spmt = malloc(processor->mmap.nspmt);
	processor->mmap.spm2 = malloc(processor->mmap.nspm2);

	processor->mmap.io = malloc(0x80000); // 8 Mio
	return 0;
}


int AX_add_core(Processor *processor)
{
	if(processor->icore > AX_core_MAX)
		return 1;

	Core *core = malloc(sizeof(Core));

	core->mmap = processor->mmap;
	core->syscall = 0;
	core->instruction = 0;
	core->cycle = 0;
	core->delay = 0;
	core->pc = 0x100/4;
	core->wram = (uint32_t*)processor->mmap.wram;


	int i;
	for(i = 0;i < AR_core_DCACHE_SIZE*2;i++)
		core->dcache[i] = 0;

	for(i = 0;i < AR_core_ICACHE_SIZE;i++)
		core->icache[i] = 0;

	for(i = 0;i < AX_core_IREG_COUNT;i++)
		core->busy_reg[i] = 0;

	for(i = 0;i < AX_core_VREG_COUNT;i++)
		core->busy_vreg[i] = 0;

	core->icachemiss = 0;
	core->dcachemiss = 0;
	core->icachemiss_cycle = 0;
	core->dcachemiss_cycle = 0;
	core->bandwidth = 0;

	processor->core[processor->icore] = core;

	processor->icore++;

	return 0;
}

int AX_exe_core(Core *core)
{
	clock_t tbegin;

	tbegin = clock();

	int error = 0,t = 0;

	while(error == 0)
	{
		error = AX_decode(core);
		AX_debug(core);
		error += AX_execute(core);

		AX_syscall_emul(core);
		core->cycle++;
/*
		if(core->cycle > 20)
			exit(0);
*/
		t++;
		if(t > 0x80000)
		{
			if(clock() > (tbegin+CLOCKS_PER_SEC) )
			{
				//printf("Cycle/Second : %ld\n",core->cycle);
				float frq = (float)core->cycle / 1000000.0f;
				printf("Frequence : %.2f MHz\n",frq);

				core->cycle = 0;
				tbegin = clock();
			}
			t = 0;
		}

		//printf("%d\n",core->pc);
	}

	printf("%ld instructions\n",core->instruction);
	printf("%ld cycle\n",core->cycle);

	printf("IPC : %f\n",(float)core->instruction/(float)core->cycle);

	return error;
}

