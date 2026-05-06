Status: **Solved**

# The White Screen of Death
## Problem Definition
Some time around October of 2025, I began experiencing sudden lock-ups presented with a blank, white screen and falling vertical lines on my monitor. This typically happened during power increases, such as compilations and gaming.

### My Initial Thoughts in Order:
1. **GPU:** I thought that the GPU tuning was the issue, or some driver problem.
2. **Power Delivery:** Maybe the power delivery to the GPU was causing it to fail?
3. **The Monitor:** The firmware may be outdated or some controller inside is de-syncing somehow.

Whatever the case, something was wrong. Here were my steps and then the conclusion:

I really did not want it to be a hardware issue, as that costs money. As a result, I went through many software diagnostics first.
1. **GPU Tuning**
  I went through clock tunings, downclocking from my once aggressive tune. I went from max clocks of 3GHz to 2.7GHz, then to 2.5GHz, well below stock. I tuned the VRAM from 2.7GHz down to around 2.5GHz and still saw these issues occur. Even over or under powering the card, giving a +15% power limit or -15% for both tries, nothing seemed to work. I had to look elsewhere.
2. **Kernel and Drivers**
  My next attempt was optimizing the kernel and drivers. The drivers were the latest from AMD and the kernel I tried upgrading, downgrading, and changing schedulers. None of these made a difference, sadly.
3. **BIOS Updates**
  I thought the issue would be memory related somehow. I discovered that my specific BIOS had issues with memory control and stability. Upon discovering this, I updated my BIOS to a much, much newer version. This caused me to lose my boot partitions, documented in boot-loss. Aside from that, it made little difference.
4. **Monitor Firmware**
  I updated my monitor firmware, as that was my last "software" related fix I could try. I still got the error afterwards. At this point, I knew it was hardware. To pinpoint where, I disconnected the monitor and ran something intensive to see if it still failed. It did. From here, I knew it was not the monitor. It was the computer.
5. **Power Delivery**
  If this was the issue, it would be the cheapest fix. I was praying it was. I swapped my power extension cables (the 8-pin ones that feed the gpu) for direct psu power connection, and suddenly the issue was gone. I had a perfectly stable system again.

### Conclusion: It was the Lian Li Strimer Plus v2 Extension Cables feeding the GPU
I simply replaced them. The problem has since been solved. Related issue could be cable degredation from overuse or voltage differences tripping it up.
