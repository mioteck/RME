#RME : RPG Maker Extender
Outil d'extension de RPG Maker (les objets étendus ne sont documentés que pour les ajouts.)

[Documentation](README.md) > [Index des commandes](Liste des commandes.md) > **Informations cartes**  
- - -  
#Informations cartes
Commandes relatives aux informations des cartes

##Liste des commandes
*    [get_tileset_id](#get_tileset_id)
*    [id_at(x, y)](#id_atx-y)
*    [map_id](#map_id)
*    [map_name](#map_name)
*    [region_id(x, y)](#region_idx-y)
*    [set_tile(value, x, y, layer)](#set_tilevalue-x-y-layer)
*    [square_passable?(x, y, direction)](#square_passablex-y-direction)
*    [switch_tileset(tileset_id)](#switch_tilesettileset_id)
*    [terrain_tag(x, y)](#terrain_tagx-y)
*    [tile_id(x, y, layer, *map_id)](#tile_idx-y-layer-map_id)


##Description des commandes
##### get_tileset_id

> Renvoi l' ID du tileset de la carte en cours

  
> 

##### id_at(x, y)

> Renvoie l'ID de l'évènement pointé par les coordonnées X,Y (0 si c'est le héros, -1 s'il n'y en a pas)

  
> Nom|Type|Description  
--- | --- | ---  
`x`|`Fixnum`|Coordonnées X de la case  
`y`|`Fixnum`|Coordonnées Y de la case  


##### map_id

> Renvoie l'ID de la map en cours

  
> 

##### map_name

> Renvoie le nom de la map en cours

  
> 

##### region_id(x, y)

> Renvoie l'ID de la région pointée par les coordonnées X,Y

  
> Nom|Type|Description  
--- | --- | ---  
`x`|`Fixnum`|Coordonnées X de la case  
`y`|`Fixnum`|Coordonnées Y de la case  


##### set_tile(value, x, y, layer)

> Change une case de tile

  
> Nom|Type|Description  
--- | --- | ---  
`value`|`Fixnum`|Valeur du tile (utilisez éventuellement la commande tile_id)  
`x`|`Fixnum`|Coordonnées X  
`y`|`Fixnum`|Coordonnées Y  
`layer`|`Fixnum`|Couche de la carte (1,2 ou 3)  


##### square_passable?(x, y, direction)

> Renvoie true si la case référencée par X, Y est passable dans la direction référencée par direction, false sinon

  
> Nom|Type|Description  
--- | --- | ---  
`x`|`Fixnum`|Coordonnées X de la case  
`y`|`Fixnum`|Coordonnées Y de la case  
`direction`|`Fixnum`|Direction (2,4,6,8)  


##### switch_tileset(tileset_id)

> Change le tileset de la carte en cours

  
> Nom|Type|Description  
--- | --- | ---  
`tileset_id`|`Fixnum`|ID du nouveau tileset  


##### terrain_tag(x, y)

> Renvoie le tag du terrain de la case pointée par les coordonnées X,Y

  
> Nom|Type|Description  
--- | --- | ---  
`x`|`Fixnum`|Coordonnées X de la case  
`y`|`Fixnum`|Coordonnées Y de la case  


##### tile_id(x, y, layer, *map_id)

> Renvoie l'ID de la tile pointée par les coordonnées X,Y

  
> Nom|Type|Description  
--- | --- | ---  
`x`|`Fixnum`|Coordonnées X de la case  
`y`|`Fixnum`|Coordonnées Y de la case  
`layer`|`Fixnum`|Numéro de la couche  
`*map_id`|`Fixnum`|ID d'une carte, si aucun argument n'est donné, map_id vaut l'id de la map courante  


