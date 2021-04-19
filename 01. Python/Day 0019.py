"""
1. Given an array, find which two numbers form the target?
"""
class array_problems:
    def __init__(self, arr, target_sum):
        self.arr = arr
        self.length = len(arr)
        self.target = target_sum

    def get_pairs(self):
        """
        1. Create a dictionary to hold the pairs
        2. The key will be the value of each array elements
        3. The value corresponding to each key would be the index of the array element which forms with sum
        """
        # dictionary to hold the pairs
        pairs = dict()

        for i in range(0, self.length):
            pairs[self.arr[i]] = arr.index(self.target-self.arr[i]) if (self.target-self.arr[i]) in self.arr else "Pair not present"

        return pairs

if __name__ == '__main__':
    arr = [2,7,11,15]
    target = 9

    # class object
    array_p1 = array_problems(arr, target)
    print(array_p1.get_pairs())
