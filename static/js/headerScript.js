import { fetchApi } from './fetchFunction.js';

const btnLogout = document.getElementById('btn-logout');

document.addEventListener('DOMContentLoaded', function () {

    btnLogout.addEventListener('click', async function () {
        
        const logout = await fetchApi('/api/users/logout');

        if (logout) location.reload();

    });

});