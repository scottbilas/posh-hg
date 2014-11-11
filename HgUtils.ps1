function Get-HgCloneRoot {
    $dir = get-item (pwd)
    while ($dir) {
        # short circuit if git repo
        if (test-path (join-path $dir.fullname .git)) {
            break
        }
        
        if (test-path (join-path $dir.fullname .hg)) {
            return $dir.fullname
        }

        $dir = $dir.parent
    }
}

function Get-HgStatus($getFileStatus=$true, $getShelveStatus=$true, $getOutgoingStatus=$true) {

    $clone = Get-HgCloneRoot
    if (!$clone) { return }

    $ProfileVars.Timing | add-member Hg @()

    function run-hg {
        $start = get-date
        $rc = hg $args
        $ProfileVars.Timing.Hg += [pscustomobject]@{ time = (get-date) - $start; command = "hg $args" }
        $rc
    }

    $untracked = 0
    $added = 0
    $modified = 0
    $deleted = 0
    $missing = 0
    $renamed = 0
    $tags = @()
    $commit = ""
    $behind = $false
    $bookmarks = ""
    $multipleHeads = $false
    $shelvedthis = 0
    $shelvedother = 0
    $outgoing = $false
    $error = ""

    if ($getFileStatus -eq $false) {
        run-hg parent | foreach {
            switch -regex ($_) {
                'tag:\s*(.*)' { $tags = $matches[1].Replace("(empty repository)", "").Split(" ", [StringSplitOptions]::RemoveEmptyEntries) }
                'changeset:\s*(\S*)' { $commit = $matches[1]}
            }
        }
        $branch = run-hg branch
        $behind = $true
        $headCount = 0
        run-hg heads $branch | foreach {
            switch -regex ($_) {
                'changeset:\s*(\S*)' { 
                    if ($commit -eq $matches[1]) { $behind=$false }
                    $headCount++
                    if ($headCount -gt 1) { $multipleHeads=$true }
                }
            }
        }
    }
    else {
        $summary = run-hg summary 2>&1
        $out = $summary | ?{ !($_ -is [Management.Automation.ErrorRecord]) }
        $err = $summary | ?{ $_ -is [Management.Automation.ErrorRecord] }

        if ($err) {
            $error = [string]$err
        }
        else {
            foreach ($line in $out) {
                switch -regex ($line) {
                    'parent: (\S*) ?(.*?)(?: \(([^)]+)\))?$' {
                        $commit = $matches[1];
                        $tags = $matches[2].Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
                        if ($matches[3]) {
                            $tags += $matches[3]
                        }
                    }
                    'branch: ([\S ]*)' { $branch = $matches[1] }
                    'update: (\d+)' { $behind = $true }
                    'pmerge: (\d+) pending' { $behind = $true }
                    'bookmarks: (.*)' { $bookmarks = $matches[1] }
                    'commit: (.*)' {
                        $matches[1].Split(",") | foreach {
                            switch -regex ($_.Trim()) {
                                '(\d+) modified' { $modified = $matches[1] }
                                '(\d+) added' { $added = $matches[1] }
                                '(\d+) removed' { $deleted = $matches[1] }
                                '(\d+) deleted' { $missing = $matches[1] }
                                '(\d+) unknown' { $untracked = $matches[1] }
                                '(\d+) renamed' { $renamed = $matches[1] }
                            }
                        }
                    }
                }
            }
        run-hg bookmarks | ?{$_}  | foreach {
            if ($_.Trim().StartsWith("*")) {
                 $split = $_.Split(" ");
                 $active= $split[2]
            }
        }
        }
    }
    
    if ($getShelveStatus -and (dir -ea silent $clone\.hg\shelved | select -first 1)) {
        # this only works if shelve names are the same as the branch (i.e. the default behavior if left unspecified)
        run-hg shelve -l | %{
            if ($_ -match '(\S+?)(-\d\d)?\s*\(') { # strip off the -03 etc that hg shelve appends to avoid dups
                $sbranch = $matches[1]
                $tbranch = $branch -replace '/', '_' # mimic hg shelve behavior
                if ($sbranch -eq $tbranch) {
                    ++$shelvedthis
                } else {
                    ++$shelvedother
                }
            }
        }
    }

    if ($getOutgoingStatus) {
        # check top change for this branch, and if it's not public, we must have outgoing changes ($TODO come up with something more accurate that isn't slow..)
        $rev = [int](run-hg log -l 1 -b . --template '{rev}')
        $phase = ?: ((run-hg phase -r $rev) -match ':\s*(.*)$') $matches[1]

        $outgoing = $phase -eq 'draft'
    }

    return @{
        "Untracked" = $untracked
        "Added" = $added
        "Modified" = $modified
        "Deleted" = $deleted
        "Missing" = $missing
        "Renamed" = $renamed
        "Tags" = $tags
        "Commit" = $commit
        "Behind" = $behind
        "MultipleHeads" = $multipleHeads
        "Bookmarks" = $bookmarks
        "Branch" = $branch
        "ShelvedThis" = $shelvedthis
        "ShelvedOther" = $shelvedother
        "Outgoing" = $outgoing
        "Error" = $error
    }
}

function Get-MqPatches($filter) {
    $applied = @()
    $unapplied = @()
    
    hg qseries -v | % {
        $bits = $_.Split(" ")
        $status = $bits[1]
        $name = $bits[2]
        
        if ($status -eq "A") {
            $applied += $name
        } else {
            $unapplied += $name
        }
    }
    
    $all = $unapplied + $applied
    
    if ($filter) {
        $all = $all | ? { $_.StartsWith($filter) }
    }
    
    return @{
        "All" = $all;
        "Unapplied" = $unapplied;
        "Applied" = $applied
    }
}

function Get-AliasPattern($exe) {
    $aliases = @($exe) + @(Get-Alias | where { $_.Definition -eq $exe } | select -Exp Name)
    "($($aliases -join '|'))"
}
