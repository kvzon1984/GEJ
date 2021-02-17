#Se encarga de encontrar a los views

from django.urls import path
from .views import index, contacto,galeria,base
urlpatterns = [
    path('', index, name="index"),
    path('contacto', contacto, name="contacto"),
    path('galeria', galeria, name="galeria"),
    path('base', base, name="base")
]