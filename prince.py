from testing import interview

class Prince(interview):
    def __init__(self, name, age, sound):
        interview.__init__(self, name, age)
        self.sound = sound

    def get_info(self):
        print(self.sound)
        print(self.name)
        print(self.age)

print("I am in prince")
cat = Prince("Prince", 4, "Meow")
cat.get_info()