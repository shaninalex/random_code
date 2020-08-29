const btn = document.querySelector('#load-more');
const area = document.getElementById('posts-area');

const post_per_page = 4;

const _load_more_str = 'Load More';
const _loading_str = 'Loading';

// Fields
const fields = [
  'post_image',   # this is custom API fields
  'author_image', # this is custom API fields
  'author_name',  # this is custom API fields
  'post_tags',    # this is custom API fields
  'title',
  'excerpt',
  'link',
];

let page = 1;

function error(error) {
  btn.remove();
}

function build_posts(data) {
  const p = document.createElement('div');
  let html = ``;
  data.map(post => {
    let post_tags = '<div class="tags-list">';
    post.post_tags.map(tag => post_tags += `<a class="tags-list-item" href="${tag.link}">${tag.name}</a>`);
    post_tags += '</div>';

    html += `
        <article class="article-item">
          <div class="article-item-image">
            <img src="${post.post_image}" alt="${post.title.rendered}">
          </div>
          <div class="article-item-body">
            <div class="article-item-body--top">
              <span class="author-img">
                <img src="${post.author_image}" alt="${post.author_name}">
              </span>
              <span class="author-by">
                By ${post.author_name}
              </span>
              <svg width="10" height="18" viewBox="0 0 10 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9.02823 0.771944C8.93971 0.61579 8.77432 0.519501 8.59486 0.519501H2.61829C2.38969 0.519501 2.19077 0.675157 2.13532 0.896921L0.143134 8.89887C0.10568 9.04769 0.139249 9.20531 0.233612 9.3259C0.327975 9.44699 0.472907 9.51751 0.626107 9.51751H2.89554L0.159702 16.8463C0.0721452 17.0798 0.170891 17.342 0.390231 17.4601C0.610567 17.5782 0.883165 17.515 1.02883 17.3142L8.99758 6.32397C9.10798 6.1727 9.12355 5.97232 9.03892 5.80501C8.95382 5.63819 8.78213 5.53314 8.59486 5.53314H6.48643L9.02188 1.27384C9.11432 1.11968 9.11675 0.928065 9.02823 0.771944Z" fill="#FFD600" /></svg>
              <div class="author-points">26</div>
            </div>
            <a href="${post.link}" class="article-item-title">${post.title.rendered}</a>
            ${post_tags}
            <div class="article-item-intro">${post.excerpt.rendered}</div>
          </div>
        </article>`;
  });
  p.innerHTML = html;
  return p;
}

function url(page) {
  let url = '/wp-json/wp/v2/posts/';
  url += `?page=${page}&per_page=${post_per_page}`;
  url += fields.map(f => `&_fields[]=${f}`).join('');
  return url;
}

document.addEventListener("posts-load", function (e) {
  const { page } = e.detail;
  btn.innerHTML = _loading_str;

  fetch(url(page))
    .then(response => {
      if (response.ok) {
        return response.json();
      }
      throw new Error('No more posts');
    })
    .then(data => {
      const posts = build_posts(data);
      area.appendChild(posts);
      btn.innerHTML = _load_more_str;
    }).catch((error) => {
      btn.setAttribute('disabled', true);
      btn.innerHTML = _load_more_str;
    });
});

btn.addEventListener("click", function (event) {
  event.preventDefault();
  page += 1;
  const posts_load = new CustomEvent("posts-load", { detail: { page: page } });
  document.dispatchEvent(posts_load);
});
