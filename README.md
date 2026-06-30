# VM Dynamic Disk Cleanup & Space Reclaimer

This is a simple script suite designed to clean up unneeded files and prepare a Windows Virtual Machine's dynamic/thin-provisioned disk for compaction. 

When you delete files in Windows, the data isn't actually removed from the disk; the space is just marked as available. Because of this, hypervisors (Hyper-V, VMware, VirtualBox, Proxmox) cannot tell that the space is free, and dynamic virtual disks will only grow, never shrink. 

This script solves that problem by automating the cleanup process and writing zeros (`0`) to all the free space using Sysinternals `SDelete`. Once the free space is zeroed, your hypervisor can safely shrink the virtual disk file on the host machine.

## What this script does:
1. Deletes Windows Temp files and User Temp files.
2. Empties the Recycle Bin.
3. Defragments the `C:` drive (consolidates data so free space is grouped together).
4. Downloads, extracts, and runs `SDelete` (with the `-z` flag) in a temporary folder.
5. Cleans up the SDelete temporary folder.

## How to Use:
1. Place `Run_Cleanup.cmd` and `Cleanup_VM.ps1` in the same folder inside your Virtual Machine.
2. Double-click `Run_Cleanup.cmd`.
3. If prompted by User Account Control (UAC), click **Yes** to run as Administrator.
4. Wait for the script to finish. (The `SDelete` zeroing process may take a while depending on the size of your virtual drive).
5. Shut down the Virtual Machine.

## Next Steps (Host Machine):
Once the VM is shut down, you must run the compact/shrink tool on your Host machine to actually reclaim the space. 

* **Hyper-V:** Run `Optimize-VHD -Path "C:\path\to\your\disk.vhdx" -Mode Full` in an elevated PowerShell.
* **VMware:** Use the VMware tool settings to "Compact" the hard disk, or use `vmware-vdiskmanager -k disk.vmdk`.
* **VirtualBox:** Run `VBoxManage modifymedium disk "C:\path\to\your\disk.vdi" --compact`.