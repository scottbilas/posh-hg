$global:PoshHgSettings = New-Object PSObject -Property @{
    #Retrieval settings
    GetFileStatus             = $true
    GetShelveStatus           = $true
    GetOutgoingStatus         = $true   

    # Before prompt
    BeforeText                = ' ['
    BeforeForegroundColor     = [ConsoleColor]::Yellow
    BeforeBackgroundColor     = $Host.UI.RawUI.BackgroundColor
    
    # After prompt
    AfterText                 = ']'
    AfterForegroundColor      = [ConsoleColor]::Yellow
    AfterBackgroundColor      = $Host.UI.RawUI.BackgroundColor

    # Errors
    ErrorForegroundColor     = [ConsoleColor]::White
    ErrorBackgroundColor     = [ConsoleColor]::DarkRed

    # Current branch
    BranchForegroundColor    = [ConsoleColor]::Cyan
    BranchBackgroundColor    = $Host.UI.RawUI.BackgroundColor
    # Current branch when not updated
    Branch2ForegroundColor   = [ConsoleColor]::DarkYellow
    Branch2BackgroundColor   = $host.UI.RawUI.BackgroundColor
    # Current branch when there are multiple heads
    Branch3ForegroundColor	 = [ConsoleColor]::Magenta
    Branch3BackgroundColor   = $host.UI.RawUI.BackgroundColor
    
    # Working directory status
    AddedForegroundColor      = [ConsoleColor]::Green
    AddedBackgroundColor      = $Host.UI.RawUI.BackgroundColor
	ModifiedForegroundColor   = [ConsoleColor]::Blue
    ModifiedBackgroundColor   = $Host.UI.RawUI.BackgroundColor
	DeletedForegroundColor    = [ConsoleColor]::Red
    DeletedBackgroundColor    = $Host.UI.RawUI.BackgroundColor
	UntrackedForegroundColor  = [ConsoleColor]::Magenta
    UntrackedBackgroundColor  = $Host.UI.RawUI.BackgroundColor
	MissingForegroundColor    = [ConsoleColor]::Cyan
    MissingBackgroundColor    = $Host.UI.RawUI.BackgroundColor
	RenamedForegroundColor    = [ConsoleColor]::Yellow
    RenamedBackgroundColor    = $Host.UI.RawUI.BackgroundColor
    
    # Tag list
    ShowTags                  = $true
    BeforeTagText             = ' '
    TagForegroundColor        = [ConsoleColor]::White
    TagBackgroundColor        = $Host.UI.RawUI.BackgroundColor
    TagSeparator              = ", "
    TagSeparatorColor         = [ConsoleColor]::White
    
    # Shelved stats
    ShowShelved               = $true
    ShelvedForegroundColor    = [ConsoleColor]::DarkGray
    ShelvedBackgroundColor    = $Host.UI.RawUI.BackgroundColor
    
    # MQ Integration
    ShowPatches                   = $false
    BeforePatchText               = ' patches: '
    UnappliedPatchForegroundColor = [ConsoleColor]::DarkGray
    UnappliedPatchBackgroundColor = $Host.UI.RawUI.BackgroundColor
    AppliedPatchForegroundColor   = [ConsoleColor]::DarkYellow
    AppliedPatchBackgroundColor   = $Host.UI.RawUI.BackgroundColor
    PatchSeparator                = ' › '
    PatchSeparatorColor           = [ConsoleColor]::White    
    
    # Status Count Prefixes for prompt
    AddedStatusPrefix             = ' +'
    ModifiedStatusPrefix          = ' ~'
    DeletedStatusPrefix           = ' -'
    UntrackedStatusPrefix         = ' ?'
    MissingStatusPrefix           = ' !'
    RenamedStatusPrefix           = ' ^'

    # Outgoing
    OutgoingText                  = '^!^'
    OutgoingForegroundColor       = [ConsoleColor]::Green
    OutgoingBackgroundColor       = $Host.UI.RawUI.BackgroundColor
}