# vRA8OrderedDisks

## Provisioning Additional Disks with vRA8 with Ordered MountPoints or Drive Letters

The title above is a vRA/vRO packaged solution available for download on [developer.vmware.com](https://developer.vmware.com/samples/7490/provisioning-additional-disks-with-vra8-with-ordered-mountpoints-or-drive-letters) by Jim Sadlek to solve the ordered disk KB problem known between vRA and vCenter.
<br/><br/><br/>
## Background
 
[Provisioning Additional Disks with vRA8](https://confluence.pscoe.vmware.com/display/KB/2020/04/10/Provisioning+Additional+Disks+with+vRA8) is an article on Confluence internal to Vmware's Professional Services Center of Engineering site.  Here's an extract from that page that summarizes the deficiency in vRA 8.
 
> *When creating blueprints containing multiple attached disks to one or more compute resources, vRA8 automates the provisioning and attachment of those disks.  ... However,  vRA does not guarantee  that the  order of disk requests  matches the  order of the disks attached to the VM.*

This workflow is the realization of the proposed design to mitigate the issue as described from this excerpt of the design proposed in the Confluence article.
 
> *In order to mitigate the effect, the following sequence will be implemented as part of extensibility workflow attached to the "compute.provision.post" event of the compute deployment lifecycle...*

See here for [more information](https://developer.vmware.com/samples/7490/provisioning-additional-disks-with-vra8-with-ordered-mountpoints-or-drive-letters).

<br/><br/>
## Manifest
- vRO Package: (com.vmware.pso.OrderedMountPoints.package)
- vRA Dynamic, Multi-Disk Blueprint (blueprint.yaml)
- Linux Guest Script (diskmount.sh)
- Windows Guest Script (diskmount.ps1)
- License.txt

<br/><br/>

## Pre-Requisite
Install [Guest Script Manager](https://developer.vmware.com/samples/7674/guest-script-manager---vro-8-x-version-technical-preview) (by Christophe Decanini)

### How to configure the Workflow
1. Import the vRO package and vRA Blueprint from here.
2. Run the Guest Script Manager Script Management workflow to "Add script configuration".  
    - Give the Resource Configuration a name, such as diskmount.sh
    - Copy and paste the Linux Bash script from the attached file into the Script content
    - Set the script parameters accordingly, such as timeout, and refresh settings, in seconds.
    - Do the same for the Powershell script, diskmount.ps1
7. Populate these Variables on the Workflow
    - linuxScriptResource & windowsScriptResource
    - linuxUsername, linuxPassword, windowsUsername, & windowsPassword
    - vraUsername & vraPassword
    - vraRestHost
8. Create a subscription in vRA that invokes this workflow on a compute post provision event.
<br/><br/>

### Notes and Assumptions:
- This workflow has a dependency on the Guest Script Manager and Guest Operations "Run Script in Guest" workflow.  Install that package if you do not already have it.
- This workflow assumes that the blueprint contains a "disks" input array that contains a "size" and a "mountpoint" sub property.  Also, the 'isWindows' logic assumes an "image" property exists on the vSphere Machine compute resource that is either "Linux" or "Windows".  
- This workflow used a custom naming template like this: ${resource.Prefix}${##}
 
Modify the workflow or blueprint to match your environment.  For example, matching constraint tags; or using static or dynamic networking; etc.
 
<br/><br/>
## Platform Version
vRealize Orchestrator 8.11.0
## Authors and Acknowledgment
Jim Sadlek
## License
MIT License, Copyright 2020 VMware, Inc.

<br/><br/>
