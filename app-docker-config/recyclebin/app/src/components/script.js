const data = require("./countryCodes.json")
const fs = require("fs")

const codes = {};
data.forEach((d) => {
    codes[d.code.toLowerCase()] = d.name.toLowerCase();
})

console.log(codes)

fs.writeFileSync("coutryCodes2.json", JSON.stringify(codes), "UTF-8")