@{
    ComputerName = 'LAB-HOST'

    SwitchName = 'LabInternal'
    NATName = 'LabNAT'
    NATSubnet = '192.168.100.0/24'
    HostIP = '192.168.100.1'
    PrefixLength = 24

    VMRoot = 'D:\HyperV'
    VHDPath = 'D:\HyperV\VHD'
    ISOPath = 'D:\HyperV\ISO'
    ExportPath = 'D:\HyperV\Export'
    BackupPath = 'D:\HyperV\Backup'

    UbuntuVM = @{
        Name = 'VM-UBUNTU'
        VCPU = 2
        StartupMemory = 2GB
        MinimumMemory = 1GB
        MaximumMemory = 6GB
        VHDSize = 100GB
        VHDName = 'VM-UBUNTU.vhdx'
        IsoPath = 'D:\HyperV\ISO\ubuntu-server.iso'
    }
}
