with open('address.txt', 'r') as f:
    lines = f.read().split('\n')
    for line in lines:
        components = line.split(',')
        try:
            print components[2]
            print components[3]
        except Exception as e:
            print(e)
            print components[0]