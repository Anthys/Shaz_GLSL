Comment généraliser l'application des générateurs?

- Solution lente mais qui marche tout le temps:
    Créer une liste des générateurs
    Faire une boucle qui teste l'application de chacun des générateur au point considéré.
    On ne retient que l'application du générateur qui minimise la distance dans l'espace étudié.

    Problème: Très lent, on fait beaucoup d'opérations, tous les passages dans la boucle sauf UN sont inutiles.


- Solution a:

    Pour le torus: Application du modulo. C'est une opération rapide, qui donne la solution exacte, et passer dedans n'est jamais une perte de temps.

    Je ne sais pas si cette solution est généralisable.

    J'ai réussi à la généraliser avec difficulté pour le manifold 6th turn, en coordonées hexagonales. Un peu chiant à coder, et surtout c'est pas automatique pour d'autres manifolds. Je pense qu'il doit y avoir moyen d'automatiser la construction du repère, puis de l'application du modulo.

Autres:

Peut-être décomposer le modulo avec des if else, afin de mieux comprendre comment généraliser cette méthode?