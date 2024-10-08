DefinitionBlock ("", "SSDT", 2, "JINLON", "HDASD3", 0x00001000)
{
    External (_SB_.PCI0.HDAS, DeviceObj)
    External (NHLA, IntObj)
    External (NHLL, IntObj)

    Scope (\_SB.PCI0.HDAS)
    {
        Name (XSTA, Zero)
        OperationRegion (PCFG, PCI_Config, Zero, 0x0100)
        Field (PCFG, AnyAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            CMND,   16, 
            Offset (0x54), 
            D0D3,   2, 
            Offset (0x55), 
            PMCS,   8
        }

        Method (_INI, 0, Serialized)  // _INI: Initialize
        {
            DBGM ("Initializing HDAS for power-down")
            DOFF ()
        }

        Method (_STA, 0, Serialized)  // _STA: Status
        {
            If ((XSTA == Zero))
            {
                DBGM ("Reporting HDAS as not present")
                Return (Zero)
            }

            Return (0x0F)
        }

        Method (DOFF, 0, Serialized)
        {
            CMND &= 0xF8
            Local0 = 0x03
            While ((Local0 > Zero))
            {
                Local1 = (PMCS & 0xFC)
                Local1 |= 0x03
                PMCS = Local1
                If (((PMCS & 0x03) == 0x03))
                {
                    DBGM ("Successfully set D3 state and disabled PCI command bits")
                    XSTA = Zero
                    Return (One)
                }

                Local0--
                Sleep (0x0A)
            }

            DBGM ("Failed to fully power down HDAS after retries")
            Return (Zero)
        }

        Method (_PS0, 0, Serialized)  // _PS0: Power State 0
        {
            DBGM ("Preventing HDAS power-on attempt")
            DOFF ()
        }

        Method (_PS3, 0, Serialized)  // _PS3: Power State 3
        {
            DBGM ("Reinforcing HDAS powered-off state")
            DOFF ()
        }

        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            DBGM ("HDAS _DSM called, returning no functionality")
            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }

        Name (_S0W, Zero)  // _S0W: S0 Device Wake State
        Name (_ADR, Zero)  // _ADR: Address
        Method (DBGM, 1, Serialized)
        {
            Debug = Concatenate ("HDAS: ", Arg0)
        }
    }
}
