import { fetchApi } from './fetchFunction.js';

const formLogin = document.querySelector('.login__forms');

document.addEventListener('DOMContentLoaded', function () {

    formLogin.addEventListener('submit', async function (event) {

        event.preventDefault();

        const formData = new FormData(this);

        let validate = await fetchApi('/api/users/validate', {

            method: 'POST',
            body: formData

        });

        if (validate.status_code == 200)
        {

            const data = Object.fromEntries(formData.entries());

            let login = await fetchApi(`/api/users/login/${data.email}`);

            if (login.status_code == 200)
            {

                console.log('deu certo');

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

            // Sweet Alert de Email ou Senha Errados

        }

    });

});