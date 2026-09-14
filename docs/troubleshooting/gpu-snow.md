Status: **Ongoing**

# GPU "Snow" Effects
## Problem definition

My monitor has been displaying strange artifacts, being white specks that flash across the screen very rarely and hardly noticeably. I can still see them if I pay attention. At first I thought my GPU was failing (as this was happening alongside the gpu-whitescreen issue), but I have since narrowed it to something more trivial.

### Initial Thoughts in Order
1. **GPU Failure**
  This has since been replaced with thoughts of what follows.
2. **Driver Issues**
  This led me to the next thought, as it was a little more than just this.
3. **Firmware and Driver Mismatch**
  I believed that the mismatch in versions of drivers and firmware contributed to some communication hiccups, causing these little artifacts.

The documented discrepancy was discovered to be the following:
`driver if version = 0x3d`
`fw if version = 0x40`
This discrepancy I believe is the main cause for this artifacting.
I primarily discovered this through `dmesg` outputs.

At the moment, the issue is ongoing as these are out of my control. It is hardly noticeable, though.
I'm watching out for AMDGPU updates or firmware releases in order to fix the issue for good.
