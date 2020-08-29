<?php 

add_action( 'rest_api_init', 'extend_post_fields' );
function extend_post_fields() {
    register_rest_field( 'post', 'post_image', array('get_callback' => 'api_get_post_image'));
    register_rest_field( 'post', 'author_name', array('get_callback' => 'api_get_author_name'));
    register_rest_field( 'post', 'author_image', array('get_callback' => 'api_get_author_image'));
    register_rest_field( 'post', 'post_tags', array('get_callback' => 'api_get_post_tags'));
}

function api_get_post_image( $object, $field_name, $request ) {
    global $post;
    return esc_url(get_the_post_thumbnail_url($post->ID, 'full'));
}

function api_get_author_name( $object, $field_name, $request ) {
    global $post;
    $author_id = get_post_field('post_author', $post->ID);
    return get_the_author_meta( 'nickname', $author_id );    
}

function api_get_author_image( $object, $field_name, $request ) {
    global $post;
    $author_id = get_post_field('post_author', $post->ID);
    return get_field('image', 'user_'.$author_id );
}

function api_get_post_tags( $object, $field_name, $request ) {
    global $post;
    $output = array();
    $post_tags = get_the_terms( $post->ID, 'post_tag');
    foreach ($post_tags as $tag) {
        array_push($output, array('name' => $tag->name, 'link' => get_tag_link($tag->term_id)));
    }
    return $output;
}
