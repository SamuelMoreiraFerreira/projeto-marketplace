import { renderProducts } from './renderProducts.js';
import { fetchApi } from './fetchFunction.js';

const catalogoContainer = document.querySelector('.catalogo__produtos');

const selectProductType = document.getElementById('filtrar');
const selectOrderBy = document.getElementById('classificar');
const selectCategorias = document.getElementById('categorias');

async function getProducts () {
    
    let url = '/api/products/get-all?';
    let args = []

    if (selectProductType.value != 0) args.push(`type=${selectProductType.value}`);

    if (selectOrderBy?.value != 0) args.push(`order=${selectOrderBy.value}`);

    if (selectCategorias.value != 0)
    {

        const filterCategory = selectCategorias.value.split('-');

        // Macacos

        if (filterCategory[0] == '1') args.push(`class_id=${filterCategory[1]}`);

        // Bloons

        else if (filterCategory[0] == '2') args.push(`bloon_type_id=${filterCategory[1]}`);

    }

    url += args.join('&');

    const response = await fetchApi(url);
    return response.data;

}

async function displaySelectCategorys () 
{

    selectCategorias.innerHTML = '';

    let categorys = await fetchApi('/api/categorys/all');
    categorys = categorys.data;

    const defaultOption = document.createElement('option');
    defaultOption.setAttribute('selected', '');
    defaultOption.setAttribute('value', '0');
    defaultOption.textContent = 'Todas';

    selectCategorias.appendChild(defaultOption);

    // Categorias Macacos

    if (selectProductType.value == 1 || selectProductType.value == 0)
    {

        const monkeysGroup = document.createElement('optgroup');
        monkeysGroup.setAttribute('label', 'Macacos');

        categorys.monkeys.forEach(category => {

            const option = document.createElement('option');
            option.setAttribute('value', `1-${category.id}`);
            option.textContent = category.name;

            monkeysGroup.appendChild(option);

        });

        selectCategorias.appendChild(monkeysGroup);

    }

    // Categorias Bloons

    if (selectProductType.value == 2 || selectProductType.value == 0)
    {

        const bloonsGroup = document.createElement('optgroup');
        bloonsGroup.setAttribute('label', 'Bloons');

        categorys.bloons.forEach(category => {

            const option = document.createElement('option');
            option.setAttribute('value', `2-${category.id}`);
            option.textContent = category.name;

            bloonsGroup.appendChild(option);

        });

        selectCategorias.appendChild(bloonsGroup);

    }

}

async function catalogo ()
{

    catalogoContainer.innerHTML = '';

    const products = await getProducts();
    renderProducts(products, catalogoContainer);

}

document.addEventListener('DOMContentLoaded', function () {

    catalogo();
    displaySelectCategorys();

    //#region Filtrar e Ordenar

    selectProductType.addEventListener('change', function () {

        catalogo();
        displaySelectCategorys();

    });

    selectOrderBy.addEventListener('change', catalogo);

    selectCategorias.addEventListener('change', catalogo);

    //#endregion

});