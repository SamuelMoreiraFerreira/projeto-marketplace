import { fetchApi } from './fetchFunction.js';

const registerForm = document.querySelector('.cadastro__form');

document.addEventListener('DOMContentLoaded', function () {

    registerForm.addEventListener('submit', async function (event) {

        event.preventDefault();

        const formData = new FormData(this);

        let register = await fetchApi('/api/users/create', {

            method: 'POST',
            body: formData

        });

        if (register.status_code == 200)
        {

            const data = Object.fromEntries(formData.entries());

            let login = await fetchApi(`/api/users/login/${data.email}`);

            if (login.status_code == 200)
            {

                console.log('deu certo');

                location.reload();

                // Sweet Alert de Confirmação

            }

            else
            {

                console.log('deu errado');

                // Sweet Alert de Erro

            }   

        }

        else
        {

            console.log('oi');

            // Sweet Alert de Erro SLA

        }

    });

});