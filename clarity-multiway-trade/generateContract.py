import json
from multiway_trade_builder import build_multiway_trade

# Using Library function!
contract_file = input("SAVE file as? [.clar] : ")

jsonFile = open("example.json", "r")
inputs = jsonFile.read()
# print(inputs)
contract_details = json.loads(inputs)
# print(contract_details)

# Library
CODE = build_multiway_trade("mainnet",contract_details)

newContract = open("autoGeneratedContracts\%s.clar"%(contract_file), "w", newline='\n')

newContract.write(CODE)

jsonFile.close()
newContract.close()
