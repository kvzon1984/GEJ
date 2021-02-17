from django.shortcuts import render


# Create your views here.
# respondo con el html

def index(request):
    return render(request, 'app/index.html')

def contacto(request):
    return render(request, 'app/contacto.html')

def galeria(request):
    return render(request, 'app/galeria')

def base(request):
    return render(request, 'app/base.html')