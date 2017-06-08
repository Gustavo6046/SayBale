# Does not work. Do not try.
console.log("WARNING: CompRun is in a non-functional state. Aborting...")

# compiler = require("./compiler.js")

# time = ->
#     +new Date()

# last = 0

# done = 0
# max = 0

# compiler.compileFolder(".", ((max2) -> max = max2), null, ((dir) -> console.log("Found #{dir}.")), ((dir) -> console.log("Recursing to #{dir}")), ((fname, max, curr) -> console.log("* Compiling #{fname} (#{curr * 100 / max}%)")), (fname, error, stdout, stderr) ->
#     console.log("#{fname} compiling stdout:\n#{stdout}\n\n\n#{fname} compiling stderr:\n#{stderr}")
#     done++
# )

# while done < max
#         if time() > last + 1500
#             console.log("* #{done} of #{max} (#{done * 100 / max}%) compiled...")
#             last = time()

# console.log("Running...")
# require("./main.js")