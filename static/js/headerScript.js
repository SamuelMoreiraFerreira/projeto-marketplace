import { fetchApi } from './fetchFunction.js';

const userinfoContainer = document.getElementById('user-info');

document.addEventListener('DOMContentLoaded', async function () {

    const response = (await fetchApi('/api/users/logged')).data;

    if (response?.is_logged)
    {

        userinfoContainer.innerHTML = '';

        const user_data = response.user_data;

        const username = document.createElement('span');
        username.textContent = user_data.first_name + ' ' + user_data.last_name;
        
        const btnLogout = document.createElement('button');
        btnLogout.setAttribute('id', 'btn-logout');
        btnLogout.textContent = 'Sair';

        btnLogout.addEventListener('click', async function () {
        
            const logout = await fetchApi('/api/users/logout');
    
            if (logout) location.reload();
    
        });

        userinfoContainer.appendChild(username);
        userinfoContainer.appendChild(btnLogout);

    }

});