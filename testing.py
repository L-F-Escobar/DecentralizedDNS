import json, pprint

with open('test.json') as data_file:    
    data = json.load(data_file)

with open('test2.json') as data_file:    
    data2 = json.load(data_file)

# pprint.pprint(data)

class interview:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        print("Base Class - interview")
    
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
        powers = {}
        name = ''

        for keys in data['members']:
            # print(keys)
            # print(type(keys))

            for innerKeys in keys:
                print(innerKeys.ljust(15), " : ", keys[innerKeys])

                if innerKeys == 'name':
                    name = keys[innerKeys]
                    if name not in powers.keys():
                        powers[keys[innerKeys]] = []

                if innerKeys == "powers":
                    for i in range(len(keys[innerKeys])):

                        powers[name].append(keys[innerKeys][i])
                        print(keys[innerKeys][i])
        
        return powers


# test = interview("Luis Driver", 31)
# listings = test.get_all_members()
# myPowers = test.get_power()
# print(myPowers.keys())




'''
    dictionary + list section
'''
# powers = {}
    ## Works because this is appending to a list
# powers['Prince'] = ['scratch']
# powers['Prince'].append('claw')
# powers['Prince'].append('moew')
# powers['Prince'].append('yawn')
# powers['Prince'].append('eat')
# powers['Prince'].append('drink')
# powers['odin'] = 'in heaven'
# print(powers)
# print(powers.keys())

# for key, value in powers.items():
#     print(key)
#     print(value)

# powers.popitem()
# print(powers)
# print(powers.get('Prince'))

# powers["Prince"].sort()
# print(powers)