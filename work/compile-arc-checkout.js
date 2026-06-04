const fs = require("fs");
const path = require("path");
const solc = require("solc");

const root = path.resolve(__dirname, "..");
const sourcePath = path.join(root, "outputs", "ArcCheckout.sol");
const source = fs.readFileSync(sourcePath, "utf8");

const input = {
  language: "Solidity",
  sources: {
    "ArcCheckout.sol": { content: source }
  },
  settings: {
    optimizer: { enabled: true, runs: 200 },
    outputSelection: {
      "*": {
        "*": ["abi", "evm.bytecode.object", "evm.deployedBytecode.object"]
      }
    }
  }
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
if (output.errors) {
  for (const error of output.errors) {
    console.error(error.formattedMessage);
  }
  if (output.errors.some((error) => error.severity === "error")) {
    process.exit(1);
  }
}

const contract = output.contracts["ArcCheckout.sol"].ArcCheckout;
const artifact = {
  abi: contract.abi,
  bytecode: `0x${contract.evm.bytecode.object}`,
  deployedBytecode: `0x${contract.evm.deployedBytecode.object}`
};

fs.writeFileSync(
  path.join(root, "outputs", "ArcCheckout.artifact.json"),
  JSON.stringify(artifact, null, 2)
);

console.log(`ABI entries: ${artifact.abi.length}`);
console.log(`Bytecode bytes: ${(artifact.bytecode.length - 2) / 2}`);
