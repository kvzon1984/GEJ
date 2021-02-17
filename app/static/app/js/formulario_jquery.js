$("#formulario_contacto").validate({
    rules:{
        nombre:{
            required: true,
            minlength: 3,
            maxlength: 50,
        },
        edad:{
            required: true,
            number: true,
            min: 1,
            max: 120
        },
        f_nacimineto:{
            required: true
        },
        direccion:{
            required: true,
            minlength: 3,
            maxlength: 50
        },

        comuna:{
            required: true,
            minlength: 3,
            maxlength: 50
        },
        fono: {
            required: true,
            number: true,
            min: 9,
            max: 9
        },
        email:{
            email: true,
            required: true
        }

    }
})

$("#guardar").click(function(){

    if(!$("#formulario_contacto").valid()){
        return
    }


    let nombre = $("#nombre").val()
    let edad = $("#edad").val()
    let f_nacimineto = $("#f_nacimiento").val()
    let direccion = $("#direccion").val()
    let comuna = $("#comuna").val()
    let fono = $("#fono").val()
    let email = $("#email").val()
    
})