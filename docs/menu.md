## menu

The top level sections of the site are looped over - each loop passes a `depth` which determines the horizontal offset.

If the `nav-tree` template is called for an item - at a minimum we will render the link.

Top level sections all call this template and so automatically have their links rendered.

#### children rendering

An item will render it's children if it's a section and it's `open` which is decided by:

 * if the item is the currentPage
 * if the item is an ancestor of the currentPage

  