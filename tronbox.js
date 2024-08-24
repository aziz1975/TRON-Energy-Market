require("dotenv").config({ path: __dirname + "/.env" });

module.exports = {
  networks: {
    nile: {
      privateKey: process.env.PRIVATE_KEY_NILE,
      userFeePercentage: 1,
      feeLimit: 15000000000,
      fullHost: "https://nile.trongrid.io",
      network_id: "*",
    },
    development: {
      privateKey: process.env.PRIVATE_KEY_DEVELOPMENT,
      fullHost: "http://127.0.0.1:9090",
      network_id: "*",
    },
    compilers: {
      solc: {
        version: "0.8.20",
      },
    },
  },
  // solc compiler optimize
  solc: {},
};
