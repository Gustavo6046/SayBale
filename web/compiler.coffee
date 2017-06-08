fs = require('fs')
path = require('path')
child_process = require('child_process')
coffee = {}

compiled = (fname, next) ->
    __wrapper__ = (err, stdout, stderr) ->
        if next?
            next(fname, err, stdout, stderr)

coffee.compileFile = (fname, next) ->
    child_process.exec("coffee -c -b #{fname}", {timeout: 10}, compiled(fname, next))

coffee.countCoffees = (foldername, fileFound, recurseCall, next) ->
    for sub in fs.readdirSync(foldername)
        sub = path.join(foldername, sub)

        if fs.lstatSync(sub).isDirectory()
            if recurseCall?
                recurseCall(sub)

            coffee.countCoffees(path.join(foldername, sub), fileFound, recurseCall)

        else if sub.endsWith(".coffee") and fileFound?
            fileFound(sub)

    if next?
        next()

coffee.compileFolderNoCount = (foldername, num, curr, done, anyFound, dirFound, fileFound, compiled) ->
    curr2 = 0
    
    for sub in fs.readdirSync(foldername)
        sub = path.join(foldername, sub)

        if anyFound?
            anyFound(sub)

        if fs.lstatSync(sub).isDirectory()
            if dirFound?
                dirFound(sub)

            coffee.compileFolderNoCount(sub, num, curr + curr2)

        else if sub.endsWith(".coffee")
            if fileFound?
                fileFound(sub, num, curr)

            curr2 += 1
            coffee.compileFile(sub, compiled)

    curr2

coffee.compileFolder = (foldername, counted, anyFound, dirCount, dirFound, fileFound, compiled, compiling, next) ->
    # Counting
    num = 0
    curr = 0
    done = 0

    done = (fname, error, stdout, stderr) ->
        done++

        if compiled?
            compiled(fname, error, stdout, stderr)

    console.log("Counting...")
    coffee.countCoffees(foldername, ((_) -> num++), dirCount, ->
        console.log("Starting compilation processes...")

        counted(num)

        for sub in fs.readdirSync(foldername)
            sub = path.join(foldername, sub)

            if anyFound?
                anyFound(sub)

            if fs.lstatSync(sub).isDirectory()
                if dirFound?
                    dirFound(sub)

                curr += coffee.compileFolderNoCount(sub, num, done, curr, anyFound, dirFound, fileFound, done)

            else if sub.endsWith(".coffee")
                if fileFound?
                    fileFound(sub, num, curr)

                curr += 1
                coffee.compileFile(sub, done)
    )

    if compiling?
        while done < num
            compiling(num, done)

    if next?
        next()

module.exports = coffee