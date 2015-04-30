#include "juniper_pci.h"

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/uio_driver.h>

#include <linux/ioport.h>
#include <asm/io.h>

#define ZYNQ_PCI_DEVCLASS "jzynq"
#define ZYNQ_DEVICE_START 0x40000000
#define ZYNQ_DEVICE_SIZE 0x40000000 // Just alloc the whole thing :)

// This is the opaque pointer used for callbacks etc.
// This just makes life easier. It might not be safe...
struct juniper_device 
{
	struct class* class;
	struct device* device;
        struct uio_info* uio_reg;

	void* iostorage;
};

void (*new_device_callback)(struct juniper_device* dev) = NULL;
void (*lost_device_callback)(struct juniper_device* dev) = NULL;

struct juniper_device* rootDevice = NULL;

int juniper_pci_register(void (*new_device)(struct juniper_device* dev), void (*lost_device)(struct juniper_device* dev))
{
	struct juniper_device* jd;
	struct class* c;
	struct device* dev;
	void* plStorage;
        struct uio_info* uio_reg;

	new_device_callback = new_device;
	lost_device_callback = lost_device;

	// This one is a little easier
	// We just need to create a virtual device and notify
	// This is a bit of a hack. We'll live :)
	// First create the class, then the actual device.
	c = class_create(THIS_MODULE, ZYNQ_PCI_DEVCLASS);
	if(c == NULL)
		return -ENODEV;

	// Then the device.
	jd = kzalloc(sizeof(struct juniper_device), GFP_KERNEL);
	dev = device_create(c, NULL, 0, jd, "jzynq");
	jd->device = dev;
	jd->class = c;

	rootDevice = jd;

	// Notify that the device has been inserted
	request_mem_region(ZYNQ_DEVICE_START, ZYNQ_DEVICE_SIZE, "jzynq");
	plStorage = ioremap(ZYNQ_DEVICE_START, ZYNQ_DEVICE_SIZE);
	jd->iostorage = plStorage;

	printk(KERN_INFO "iostorage at 0x%p\n", plStorage);

        // Register a UIO driver.
        uio_reg = kzalloc(sizeof(struct uio_info), GFP_KERNEL);
        if(!uio_reg)
            return -ENOMEM;
        uio_reg->name = "juniper_uio";
        uio_reg->version = "0.1";
        uio_reg->mem[0].name = "juniper_uio_mem";
        uio_reg->mem[0].memtype = UIO_MEM_PHYS;
        uio_reg->mem[0].addr = ZYNQ_DEVICE_START; // LOL MAGIC NUMBERS
        uio_reg->mem[0].size = 512*1024*1024; // Er...512M was probably mapped...

        // Register it!
        if(uio_register_device(dev, uio_reg))
            return -ENOSYS;
        jd->uio_reg = uio_reg;

        // Traditionally, the callback would be called from a probe function
        // to notify of a new device. Since there's only one reconfig, we just
        // emulate device discovery here...
        // This should then cause juniper_sysfs to go and create all the nice
        // device nodes.
	new_device_callback(jd);

	return 0;
}

void juniper_pci_unregister()
{
	lost_device_callback(rootDevice);

        
        uio_unregister_device(rootDevice->uio_reg);
	iounmap(rootDevice->iostorage);
	release_mem_region(ZYNQ_DEVICE_START, ZYNQ_DEVICE_SIZE);

	device_del(rootDevice->device);
	class_unregister(rootDevice->class);
	class_destroy(rootDevice->class);

	kfree(rootDevice);
}

struct device* juniper_pci_getdev(struct juniper_device* dev)
{
	return dev->device;
}

unsigned int juniper_pci_devidx(struct juniper_device* dev)
{
	return 0; // Only have old PL
}


unsigned int juniper_pci_read(struct juniper_device* dev, unsigned int address)
{
	char* plStorageBase = (char*)dev->iostorage;
	plStorageBase += address;

	return ioread32(plStorageBase);
}

void juniper_pci_write(struct juniper_device* dev, unsigned int address, unsigned int value)
{
	char* plStorageBase = (char*)dev->iostorage;
	plStorageBase += address;

	iowrite32(value, plStorageBase);
}

// Consider making these actual DMA later...
void juniper_pci_read_burst(struct juniper_device* dev, unsigned int base_address, unsigned int* data, unsigned int count)
{
	char* plStorageBase = (char*)dev->iostorage;
	plStorageBase += base_address;

	//printk(KERN_INFO "Reading %d bytes from 0x%p\n", count, plStorageBase);

	*data = ioread32(plStorageBase);
	//memcpy_fromio(data, plStorageBase, count);
}

void juniper_pci_write_burst(struct juniper_device* dev, unsigned int base_address, unsigned int* data, unsigned int count)
{
	char* plStorageBase = (char*)dev->iostorage;
	plStorageBase += base_address;

	memcpy_toio(plStorageBase, data, count);
}