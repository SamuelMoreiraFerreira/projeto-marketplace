//#region Carrosel

const carousel = document.querySelector('.carousel');

new bootstrap.Carousel(carousel, {

    interval: 2000,
    touch: false

});

//#endregion

import { renderProducts } from "./renderProducts.js";
import { fetchApi } from "./fetchFunction.js";

const highlightsContainer = document.querySelector('.catalogo__produtos');

document.addEventListener('DOMContentLoaded', async function () {

    // Destaques

    let highlights = await fetchApi('/api/products/get-highlights/4');
    highlights = highlights.data;

    renderProducts(highlights, highlightsContainer);

});