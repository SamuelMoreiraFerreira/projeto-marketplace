async function fetchApi(url) 
{
    
    try
    {

        let request = await fetch(url);
        request = await request.json();

        if (request.status_code != 200) return false;

        return request;
        
    }

    catch (e)
    {

        console.log(`Erro - Fetch API "${url}"`);
        return false;

    }

}

export
{
    fetchApi
}