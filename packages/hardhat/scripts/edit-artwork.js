const fs = require("fs");

fs.readFile("./artwork-pokemon.json", "utf8", (err, jsonString) => {
  if (err) {
    console.log("File read failed:", err);
    return;
  }

  try {
    const pokemonArray = JSON.parse(jsonString);
    for (let i = 0; i < pokemonArray.length; i++) {
      let attributeObj = pokemonArray[i]["attributes"];
      attributeObj = [
        { trait_type: "PokedexID", value: i + 1 },
        ...attributeObj,
      ];
      pokemonArray[i]["attributes"] = attributeObj;
    }

    fs.writeFile(
      "./new-pokemon-artwork.json",
      JSON.stringify(pokemonArray, null, 2),
      (err) => {
        if (err) {
          console.log("Failed to write updated data to file");
          return;
        }
        console.log("Updated file successfully");
      }
    );
  } catch (err) {
    console.log(err);
  }
});
