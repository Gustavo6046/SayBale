access = (url) ->
    console.log(url)

    if url == "."
        $.ajax("../source", {
            type: "GET"
            success: (data, status, req) ->
                document.getElementsByTagName("BODY")[0].innerHTML = new DOMParser().parseFromString(data, "text/html").body.innerHTML
        })

    else if url.endsWith("/") or url.endsWith("\\")
        $.ajax("../source", {
            type: "POST"
            data: {
                pos: url
                type: "dir"
            }
            success: (data, status, req) ->
                document.getElementsByTagName("BODY")[0].innerHTML = data
        })

    else
        $.ajax("../source", {
            type: "POST"
            data: {
                pos: url
                type: "file"
            }
            success: (data, status, req) ->
                document.getElementsByTagName("BODY")[0].innerHTML += data
        })