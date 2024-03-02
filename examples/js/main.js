import { readFile } from "fs";
import { foo } from "./foo.js";

try {
  const text = await readFile("./js/text.txt");
  console.log(text)
} catch (error) {
  console.log(error)
}

console.log(foo());