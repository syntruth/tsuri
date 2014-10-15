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

Tsuri provides several methods of traversing the tree structure. The most straight
forward of which is `each()` (or `traverseDown` which are the same). Each of the
traversing methods takes an iterator function, which will be provided the node as
the sole argument:

    function iterator(node) { console.info(node.data.name); }

    // => root
    //    child-1
    //    child-2
    //    grandchild-1

*Note:* Within the iterator function, the value of `this` is set to the current node
being traversed. So, the iterator could have been written as:

    functon iterator() { console.info(this.data.name); }

The following are the traversal methods:

- `each()`/`traverseDown()`: Traverses from a given node down the tree, in a
  left-to-right fashion.
- `traverseUp()`: Traverses from a given node back up the tree, and then down
  again once the root node has been reached, in a left-to-right fashion.
- `breadthEach()`: Traverses the tree in a left-to-right, top-to-bottom fashion.
- `postOrderEach()`: Traveres the tree from the leafs updwards towards the root,
  so leaves are iterated before their parents.

See each method below for an example.

## Methods

The following public methods are defined on the Tsuri instance object.

**appendChild**(data, id = undefined) => Tsuri object  
This will append the data as a new Tsuri node to the node object this is called on.
An optional `id` value can be passed as the ID of the new node, otherwise, the default
node ID will be assigned.

**breadthEach**(iterator) => null  
This will traverse the tree, starting at the node that this was called on, doing a
breadth-first, left-to-right traversal of the subtree.

    tree.breadthEach(function(node) { console.info(node.data.name); })

    // => root
    //    child-1
    //    child-2
    //    grandchild-1

**each**(iterator) => null  
This is a synonym for traverseDown() below.

**find**(finder) => Tsuri instance or null  
This will find a given node within the (sub)tree node this is called on. The `finder`
argument is a function with the following signature:

    function finder(node) { ... }

Example:

    var node = tree.find(function(node) {
      return node.data.name === 'grandchild-1';
    });

The finder function should return true or false on if the node matches what you are
looking for in the tree. If found, the node will be returned, otherwise null will
be returned.

**hasChildren**() => Boolean  
Returns true if the given node has children, false otherwise.

**isLeaf**() => Boolean  
Will return if this node is a leaf or not; that is, if it has any children
or not.

**isRoot**() => Boolean  
Will return if the node this is called on is the root of the tree or not.

**path**(path, separator = '/') => Tsuri instances or null  
Finds a node based on a string path of children indexes, separated by the optional
separator string, which defaults to '/'. In other words, using the above JSON data,
from the tree root, the path to the `grandchild-1` node would be: 1/0, where 1 is
the 2nd child of the root node, and 0 is the 1st child of the `child-2` node.

**postOrderEach**(iterator) => null  
This traverses the tree, starting with the node this was called on, in post-ordered,
order. That is, leafs at the end of each branch is iterated first, with this node,
or root, being the last node iterated.

    tree.postOrderEach(function(node) { console.info(node.data.name); })

    // => child-1
    //    grandchild-1
    //    child-2
    //    root

**remove**() => Tsuri instance or null  
This will remove the node that that is called upon from its parent node. It will
return the removed node, or null if the node has no parent.

**root** () => Tsuri instance  
This returns the root node regardless on which node this is called upon.

**removeChild**(node) => Tsuri instance or null  
This will remove a child node from the node this is called upon. The `node`
argument can either be a Tsuri instance or an integer representing the indexed
position of the node within its parents children array.

**siblings**() => [Tsuri instances] or []  
This will return an array of nodes that are siblings of the node that this is
called on, or if this node has no siblings, an empty array.

**size**() => Integer  
This will return how many nodes are in the (sub)tree of this node, including
this node.

**toArray**() => [Tsuri instances]  
This will return a flat array of all the nodes, starting with the root node. Nodes
higher up in the tree are towards the front of the array, and thus those lower down
in the tree are towards the end of the array.

**toJSON**(childrenAttr, dataHandler) => Object  
This will return a JSON object representation of the tree; it is sort of the
opposite of Tsuri.parse(). The `childrenAttr` tells the method what attribute
to use for the children array, and defaults to 'children'. The dataHandler is an
optional function so you can massage how the data is returned. This function
*_must_* return an Object. If left undefined, a default data handler is used which
simply returns node.data.

**toString**() => String  
This returns a string representation of the tree, with the IDs listed for each node.

    tree.toString()

    // => 0
    //     |--> 0-0
    //     |--> 0-1
    //          |--> 0-1-0

**traverseUp**(iterator) => null   
This will traverse updward from the given node, feeding the iterator function each
node in turn. Each node will be visited, after the root node is reached.

    node.traverseUp(function(node) { console.info(node.data.name); return true})

    // => grandchild-1
    //    child-2
    //    root
    //    child-1

**traverseDown**(iterator) => null  
This will traverse downward from the given node, feeding the iterator function each
node in turn. This is a depth-first, left-to-right traversal.

    tree.traverseDown(function(node) { console.info(node.data.name); })

    // => root
    //    child-1
    //    child-2
    //    grandchild-1

