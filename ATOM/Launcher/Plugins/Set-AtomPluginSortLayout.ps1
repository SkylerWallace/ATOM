function Set-AtomPluginSortLayout {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode
    )

    Update-AtomPluginList -SortMode $SortMode
    Update-AtomCatalogFilter
}
