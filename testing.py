import json, pprint

with open('test.json') as data_file:    
    data = json.load(data_file)

# pprint.pprint(data)

class interview:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    def getName(self):
        print(self.name)
    
    def getAge(self):
        print(self.age)

    def get_all_members(self):
        memberList = []
        for keys in data['members']:
            print(keys)
            memberList.append(keys)

        return memberList
    
    def get_power(self):
        powers = []

        for keys in data['members']:
            # print(keys)
            # print(type(keys))

            for innerKeys in keys:
                # print(innerKeys.ljust(15), " : ", keys[innerKeys])

                if innerKeys == "powers":
                    for i in range(len(keys[innerKeys])):
                        print(keys[innerKeys][i])


test = interview("Luis Driver", 31)

# listings = test.get_all_members()
# print(listings[0])
test.get_power()
    