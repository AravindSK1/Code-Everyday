"""
Singly Linked list
    1. class nodes : data, next
    2. class linked list: impor
    3. add nodes to linked list
    4. print linked list
"""


class Nodes:
    def __init__(self, data):
        self.data = data
        self.next = None # stores the node object

class LinkedList:
    # initialize head as None for emplty linked list
    def __init__(self):
        self.head = None

    # length of the linked list
    def list_length(self):
        currentNode = self.head
        length = 1
        while currentNode.next is not None:
            currentNode = currentNode.next
            length+=1
        return length

    # insert node at head
    def insertNode_head(self, newNode):
        """
        1. Create a temp node and store the current head node
        2. Make the new node as the head node
        3. Make the next of your new node point to the temp node
        4. Del the temp node
        """
        tempNode = self.head
        self.head = newNode
        self.head.next = tempNode
        del tempNode

    # insert a new node at the end of the list
    def insertNode_last(self, newNode):
        if self.head is None:
            self.head = newNode
        else:
            # find the last node
            """
            1. To find the last node, traverse through the linked list
            2. Start with the head
            3. if head.next is not None, then go to the next node
            """
            lastNode = self.head
            while True:
                if lastNode.next is None:
                    break
                lastNode = lastNode.next
            lastNode.next = newNode

    # insert node at desired position
    def insertNode_at(self, newNode, position):
        # insert at head
        if position == 0:
            self.insertNode_head(newNode)
            return

        # to handle negative positions
        if position < 0:
            print("Incorrect position.. Inserting the element at the head")
            self.insertNode_head(newNode)
            return

        # to handle position greater than the list lenght
        len_list = self.list_length()
        if position > len_list:
            print(f"Incorrect position.. Current list length is {len_list}. Inserting the element at the end of the list..")
            self.insertNode_last(newNode)
            return

        # For position between head and tail
        current_position = 0
        currentNode = self.head
        while True:
            if position == current_position:
                """
                1. Store the details of the previous node
                2. Make a connection from the next of the previous node to the new node
                3. Make a connection from the next of the newNode to the node at position
                4. The position gets changed. The new node becomes the node at position
                5. The node at position becomes position + 1
                """
                previousNode.next = newNode
                newNode.next = currentNode
                break
            previousNode = currentNode
            currentNode = currentNode.next
            current_position += 1

    # delete a node at the end of the list
    def deleteNode_last(self):
        """
        1. Traverse till the end of the list
        2. 
        """

    # print linked list
    def printList(self):
        if self.head is None:
            print("List is empty")
        currentNode = self.head
        while True:
            if currentNode is None:
                break
            print(currentNode.data)
            currentNode = currentNode.next

if __name__ == '__main__':
    # data
    firstnode = Nodes("Aravind")
    secondnode = Nodes("Rishi")
    thirdnode = Nodes("Amma and Appa")

    # create a linked list object
    ll = LinkedList()

    # nodes to be inserted sequentially
    nodes = [firstnode, secondnode]

    # start adding nodes at the last
    for n in nodes:
        ll.insertNode_last(n)

    # insert node at a specific position
    ll.insertNode_at(thirdnode,10)

    # print the linked list
    ll.printList()
