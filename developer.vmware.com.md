## Background
 
[Provisioning Additional Disks with vRA8](https://confluence.pscoe.vmware.com/display/KB/2020/04/10/Provisioning+Additional+Disks+with+vRA8) is an article on Confluence internal to Vmware's Professional Services Center of Engineering site.  Here's an extract from that page that summarizes the deficiency in vRA 8.
 
> *When creating blueprints containing multiple attached disks to one or more compute resources, vRA8 automates the provisioning and attachment of those disks.  ... However,  vRA does not guarantee  that the  order of disk requests  matches the  order of the disks attached to the VM.*

This workflow is the realization of the proposed design to mitigate the issue as described from this excerpt of the design proposed in the Confluence article.
 
> *In order to mitigate the effect, the following sequence will be implemented as part of extensibility workflow attached to the "compute.provision.post" event of the compute deployment lifecycle:*

> 
1. Obtain reference to a *VC:VirtualMachine* object from the vCenter plugin in vRO and using the element contained in the *externalIds* property of the *inputProperties* object.
2. Iterate over the device configuration of the *VirtualMachine* object (vm.config.hardware.device ) and extract only the items that contain the string \"Hard Disk\" in their label. This will result in an **ordered list** of disk devices.
3. Preserving the order of the list, for each disk device extract the last segment of the file from the VMDK path without the **.vmdk** extension, e.g. [Datastore01] Compute-mcm709-134979764077\/**Disk2-mcm707-134979759940**.vmdk. This will result in an **ordered list** of Disk names.
4. Get the deployment resources of the deployment using the Deployment Service API in vRA.
5. Find the provisioned compute resource from the list of all compute resources (having type *Cloud.vSphere.Machine*) by comparing the resource IDs with the one contained in the *inputProperties* object.
6. Extract the attached disks from the found compute resource using the *attachedDisks* property.
7. Find the provisioned disk resources from the list of all disk resources (having type *Cloud.vSphere.Disk*) by comparing their IDs with the IDs of the attached disks of the provisioned compute resource.
8. Sort the provisioned disk resources using the ordered list of disk names obtained from step (3) by comparing the values of the disk names (from step (3)) and the values of the *resourceName* property of the disks (from step (7)).

> *The resulting ordered list will follow the order of attachment and will contain all properties input by the user. An in-guest script for disk mounting and disk formatting can be safely implemented using values following this order.*

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

Courtesy [markdowntohtml.com](https://markdowntohtml.com)
