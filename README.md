INTRODUCTION
==============================================================================

**oil.vim**: *combine with vinegar, or plain netrw, for a delicious salad dressing.*

Plugin to create a Netrw Explorer Project Drawer.  It uses [Netrw](http://vimdoc.sourceforge.net/htmldoc/pi_netrw.html) and compliments [vim-vinegar](https://github.com/tpope/vim-vinegar).

It is created for those who like a Docked Explorer and for those new to Vim. It can even be useful to those who like the split-windows-explorer approach.

     [project drawer] still has its place, particularly during the orientation phase with a new codebase.
     - Drew Neil, Oil and vinegar Vimcast

This plugin is inspired by

1. [vim-vinegar](https://github.com/tpope/vim-vinegar), and
2. the [Oil and vinegar](http://vimcasts.org/blog/2013/01/oil-and-vinegar-split-windows-and-project-drawer/) Vimcast
3. my not finding one that uses Netrw to implement a project drawer, while still allowing the split window approach, i.e., oil *AND* vinegar.

Note: It is only tested on Vim 7.4, but should work on older versions too.

MAPPINGS
==============================================================================
**`<Leader>e`** : ***e***xplore. Set to `OilWhisk` by default.

COMMANDS
==============================================================================

**`OilWhisk`** Cycles between Netrw windows and buffers.

**`OilShake`** Toggles display of the Netrw window.

SETTINGS
==============================================================================

The following settings are all boolean; set them to any value to enable them.

**`g:loaded_oil`** Set before sourcing to disable plugin.

**`g:oil_right`**  Display the drawer on the right, instead of the left.

**`g:oil_multi`**  Allow more than one Netrw window. `OilWhisk` will cycle through each window.

**`g:oil_shake`**  Set default mapping to `OilShake` to toggle the Netrw window.

**`g:oil_no_map`** Disable default key mapping (`<Leader>e`).

CONTRIBUTIONS
==============================================================================

Contributions and pull requests are welcome.

LICENSE
==============================================================================

GPL v3 or later
