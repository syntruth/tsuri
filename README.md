Tsuri
=====

A Javascript Tree-Structure library.

This is a fork of the [Arboreal](https://github.com/afiore/arboreal) javascript library.

I forked that project because Tsuri is **not** a drop-in replacement for Arboreal, as I've
changed a few things and added some new methods for the tree-structure class.

## Usage

    root = new Tsuri(null, data);

    root
      .appendChild(childData1)
      .appendChild(childData2)
      .children[0]
        .appendChild(grandchildData1)
        .appendChild(grandchildData2);

Or, you can use the parse class method. Parse takes an object as the first argument,
and an optional string that tells it what property to look at for the children
array within that object; by default, the children attribute string is simply
'children'.

    var json = {
      "name": "root",
      "content": "root content",
      "children": [
        {"name": "child-1", "content": "child 1 content"},
        {
          "name": "child-2",
          "content": "child 2 content",
          "children": [
            {"name": "grandchild-1", "content": "grandchild 1 content"}
          ]
        }
      ]
    };

    tree = Tsuri.parse(json);

Each node within the tree is given an ID string, representing the depth and index of
that node in the tree structure. By default, these are dash-separated numbers.

    tree.children[1].children[0].id => "0-1-0"

## Traversal

    function iterator(node) { console.info(node.data.name); }

    // => root
    //    child-1
    //    child-2
    //    grandchild-1

*Note:* Within the iterator function, the value of `this` is set to the current node
being traversed. So, the iterator could have been written as:

    functon iterator() { console.info(this.data.name); }


