async function fetchApi(url, data={}) 
{
    
    try
    {

        let request = await fetch(url, data);
        request = await request.json();

        if (request.status_code != 200) return false;

        return request;
        
    }

    catch (e)
    {

        console.log(`Erro - Fetch API "${url}": ${e}`);
        return false;

    }

}

export
{
    fetchApi
}