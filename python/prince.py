from testing import interview
import json

with open('test2.json') as data_file:
    data2 = json.load(data_file)

# print(data2)

class Prince(interview):
    def __init__(self, name, age, sound):
        interview.__init__(self, name, age)
        self.sound = sound

    def get_info(self):
        print(self.sound)
        print(self.name)
        print(self.age)
    

    def get_data_keys(self):
        for keys in data2:
            print(keys)


    def reverse_word(self, word):
        print(("word is: ").ljust(14), word)
        index = len(word) + 1
        newWorld = ""
        #range(start, stop, step)
        for i in range(-1, index*-1, -1):
            # print(word[i])
            newWorld += word[i]
        
        print(("new word is: ").ljust(14), newWorld)
    

    def break_down_word(self, word):
        word.lower()
        word_breaker = {}

        for letter in word:
            if letter not in word_breaker.keys():
                word_breaker[letter] = 1
            else:
                total = word_breaker[letter]
                total += 1
                word_breaker[letter] = total
        print(word_breaker)


    def compare_words(self, word1, word2):
        word1.lower()
        word2.lower()

        word1Dict = {}
        word2Dict = {}

        if len(word1) != len(word2):
            print("Words are not the same!")
        else:
            for letter in word1:
                if letter not in word1Dict.keys():
                    word1Dict[letter] = 1
                else:
                    total = word1Dict[letter]
                    total += 1
                    word1Dict[letter] = total

            for letter in word2:
                if letter not in word2Dict.keys():
                    word2Dict[letter] = 1
                else:
                    total = word2Dict[letter]
                    total += 1
                    word2Dict[letter] = total
        
        print(("Word 1:").ljust(15), word1Dict.keys().sort())
        print(("Word 2:").ljust(15), word2Dict)

print("I am in prince")
cat = Prince("Prince", 4, "Meow")
# cat.get_info()
# cat.get_data_keys()
# cat.reverse_word("World")
# cat.break_down_word("WorldW")
# cat.compare_words("puppies", "doggies")

testing = 666
print(testing)
testing = "leather"
print(testing)

testlist = {}
testlist["LUIS"] = 666
print(testlist)
testlist.pop("LUIS")
print(testlist)