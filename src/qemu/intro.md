## What is QEMU/KVM ?

---
### Installation

For `Ubuntu` based system :- 

**Step 1**: Update the packages

```
sudo apt update
```

**Step 2:** Install `QEMU/KVM`

```
sudo apt install qemu-kvm
```

**Step 3:** Install `libvirt`

```
sudo apt install libvirt-daemon-system libvirt-clients
```

**Step 4:** Adding the user to `kvm` group

```
sudo usermod -aG kvm $USER
```

> **Note:** Restart the system so that the group changes may come in effect.

**Step 5:** List the groups that user belong to check it is added in the `kvm` group
```
groups $USER
```

- You'll see two new groups `kvm` and `libvirt` and your user is added to these groups.

**Step 6:** To verify and make sure `kvm` is correctly installed

```
virsh list --all
```
- This command will run successfully and list all the created virtual machine.
- *Currently it is empty, as we don't have any virtual machines created*

**Step 7:** Install `virt-manager` a graphical user interface to create virtual machines.

```
sudo apt install virt-manager
```

---
### Creating our first virtual machine using `virt-manager` gui

**Step 1:** Open Virtual Machine Manager

![Virtual Manager GUI Demo](./assets/intro-assets/virt-manager-gui-demo.png "Virtual Machine Manager GUI")

**Step 2:** Click on New VM button from the task-bar

![Virtual Machine Manager New VM Button](./assets/intro-assets/virt-manager-new-vm-button.png "New VM Button")

- ***Above is the create new VM button***

![Virtual Machine Manager Create New VM](./assets/intro-assets/virt-manager-create-new-vm.png "Create New VM")

- You can select your preferred way to load operating system ISO
- For this guide, I've downloaded the [trisquel gnulinux ISO](https://trisquel.info/) , so I'll select local install media option.

**Step 3:** Browse and Choose the ISO image path

![Choose the ISO image](./assets/intro-assets/intro-assets-a.png "Choose ISO Image")

![Locate ISO Image](./assets/intro-assets/intro-assets-b.png "Locate ISO Image")

**Step 4:** Choose memory and CPU settings
    
![Choose Memory and CPU](./assets/intro-assets/intro-assets-c.png "Choose Memory and CPU")

**Step 5:** Select the storage

![Select Storage](./assets/intro-assets/intro-assets-d.png "Select Storage")

**Step 6:** Confirm and create new Virtual Machine

![Confirm and Create VM](./assets/intro-assets/intro-assets-e.png "Confirm and Create VM")

---
#### Finally the newly created VM start

![Newly Created VM](./assets/intro-assets/intro-assets-f.png "Newly Created VM")
