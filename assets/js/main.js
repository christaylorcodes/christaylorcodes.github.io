// Mobile navigation toggle
document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');

    if (navToggle) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');

            // Animate hamburger
            const hamburger = this.querySelector('.hamburger');
            hamburger.classList.toggle('active');
        });
    }

    // Close mobile menu when clicking on a link
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            if (window.innerWidth <= 768) {
                navMenu.classList.remove('active');
            }
        });
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        const isClickInsideNav = navMenu.contains(event.target) || navToggle.contains(event.target);
        if (!isClickInsideNav && navMenu.classList.contains('active')) {
            navMenu.classList.remove('active');
        }
    });

    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Form submission handling (for contact form)
    const contactForm = document.querySelector('.contact-form form');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            // Note: Add your form handling logic here
            // This is a placeholder that prevents default submission
            // You'll need to integrate with a backend service or use a service like Formspree
            console.log('Form submitted');
        });
    }

    // Add animation on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe feature cards and project cards
    document.querySelectorAll('.feature-card, .project-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
});

// Add active state to current page in navigation
window.addEventListener('load', function() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-link');

    navLinks.forEach(link => {
        if (link.getAttribute('href') === currentPath ||
            (currentPath === '/' && link.getAttribute('href') === '/') ||
            (currentPath.includes(link.getAttribute('href')) && link.getAttribute('href') !== '/')) {
            link.classList.add('active');
        }
    });
});

// Blog post filtering functionality
document.addEventListener('DOMContentLoaded', function() {
    const filterButtons = document.querySelectorAll('.filter-btn');
    const paginatedContainer = document.querySelector('.blog-posts-paginated');
    const allPostsContainer = document.querySelector('.blog-posts-all');
    const paginationControls = document.querySelector('.pagination');
    const paginationInfo = document.querySelector('.pagination-info');

    if (filterButtons.length > 0) {
        filterButtons.forEach(button => {
            button.addEventListener('click', function() {
                const filterValue = this.getAttribute('data-filter');

                // Update active button state
                filterButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');

                // Remove any existing no-results message
                const existingNoResults = document.querySelector('.no-filter-results');
                if (existingNoResults) {
                    existingNoResults.remove();
                }

                if (filterValue === 'all') {
                    // Show paginated posts, hide filtered posts
                    if (paginatedContainer) paginatedContainer.style.display = 'grid';
                    if (allPostsContainer) allPostsContainer.style.display = 'none';
                    if (paginationControls) paginationControls.style.display = 'flex';
                    if (paginationInfo) paginationInfo.style.display = 'block';
                } else {
                    // Show all posts container for filtering, hide pagination
                    if (paginatedContainer) paginatedContainer.style.display = 'none';
                    if (allPostsContainer) allPostsContainer.style.display = 'grid';
                    if (paginationControls) paginationControls.style.display = 'none';
                    if (paginationInfo) paginationInfo.style.display = 'none';

                    // Filter posts in the all posts container
                    const allPosts = allPostsContainer.querySelectorAll('.blog-post-card');
                    let visibleCount = 0;

                    allPosts.forEach(post => {
                        const postCategories = post.getAttribute('data-categories');
                        if (postCategories && postCategories.includes(filterValue)) {
                            post.style.display = 'block';
                            post.style.animation = 'fadeInUp 0.5s ease';
                            visibleCount++;
                        } else {
                            post.style.display = 'none';
                        }
                    });

                    // Show message if no posts match filter
                    if (visibleCount === 0) {
                        const message = document.createElement('div');
                        message.className = 'no-filter-results';
                        message.innerHTML = '<i class="fas fa-search"></i><p>No posts found in this category.</p>';
                        allPostsContainer.appendChild(message);
                    }
                }
            });
        });
    }

    // Dropdown toggle functionality
    const dropdown = document.querySelector('.filter-dropdown');
    const dropdownBtn = document.querySelector('.filter-dropdown-btn');
    const dropdownItems = document.querySelectorAll('.filter-dropdown-item');

    if (dropdownBtn) {
        dropdownBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            dropdown.classList.toggle('active');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            if (!dropdown.contains(e.target)) {
                dropdown.classList.remove('active');
            }
        });

        // Handle dropdown item selection
        dropdownItems.forEach(item => {
            item.addEventListener('click', function(e) {
                e.stopPropagation();
                dropdown.classList.remove('active');
                // The filter button handler will take care of the filtering
            });
        });
    }
});

// Add copy button to code blocks
document.addEventListener('DOMContentLoaded', function() {
    const codeBlocks = document.querySelectorAll('.post-content pre');

    codeBlocks.forEach(block => {
        // Create copy button
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-code-btn';
        copyButton.innerHTML = '<i class="far fa-copy"></i> Copy';
        copyButton.setAttribute('aria-label', 'Copy code to clipboard');

        // Wrap code block in container if not already wrapped
        if (!block.parentElement.classList.contains('code-block-wrapper')) {
            const wrapper = document.createElement('div');
            wrapper.className = 'code-block-wrapper';
            block.parentNode.insertBefore(wrapper, block);
            wrapper.appendChild(block);
            wrapper.appendChild(copyButton);
        } else {
            block.parentElement.appendChild(copyButton);
        }

        // Copy functionality
        copyButton.addEventListener('click', async function() {
            const code = block.querySelector('code');
            const textToCopy = code ? code.textContent : block.textContent;

            try {
                await navigator.clipboard.writeText(textToCopy);

                // Visual feedback
                copyButton.innerHTML = '<i class="fas fa-check"></i> Copied!';
                copyButton.classList.add('copied');

                // Reset button after 2 seconds
                setTimeout(() => {
                    copyButton.innerHTML = '<i class="far fa-copy"></i> Copy';
                    copyButton.classList.remove('copied');
                }, 2000);
            } catch (err) {
                console.error('Failed to copy code:', err);
                copyButton.innerHTML = '<i class="fas fa-times"></i> Failed';

                setTimeout(() => {
                    copyButton.innerHTML = '<i class="far fa-copy"></i> Copy';
                }, 2000);
            }
        });
    });
});

// Search functionality
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('search-input');
    const searchButton = document.getElementById('search-button');
    const searchResults = document.getElementById('search-results');

    if (!searchInput || !searchButton || !searchResults) {
        return; // Not on search page
    }

    let searchIndex = [];
    let isLoading = false;

    // Fetch search index
    async function loadSearchIndex() {
        if (isLoading || searchIndex.length > 0) {
            return;
        }

        isLoading = true;

        try {
            const response = await fetch('/search.json');
            if (!response.ok) {
                throw new Error('Failed to load search index');
            }
            searchIndex = await response.json();
        } catch (error) {
            console.error('Error loading search index:', error);
            searchResults.innerHTML = '<p class="search-error">Error loading search index. Please try again.</p>';
        } finally {
            isLoading = false;
        }
    }

    // Perform search
    function performSearch(query) {
        if (!query || query.trim().length === 0) {
            searchResults.innerHTML = '<p class="search-instructions">Enter a search term to find blog posts and projects.</p>';
            return;
        }

        const queryLower = query.toLowerCase().trim();
        const results = [];

        // Search through index
        searchIndex.forEach(item => {
            let score = 0;
            const titleLower = item.title.toLowerCase();
            const excerptLower = item.excerpt ? item.excerpt.toLowerCase() : '';
            const contentLower = item.content ? item.content.toLowerCase() : '';
            const tagsLower = item.tags ? item.tags.join(' ').toLowerCase() : '';
            const categoriesLower = item.categories ? item.categories.join(' ').toLowerCase() : '';

            // Scoring system (higher score = better match)
            if (titleLower.includes(queryLower)) {
                score += 10; // Title matches are most important
            }
            if (excerptLower.includes(queryLower)) {
                score += 5; // Excerpt matches are important
            }
            if (tagsLower.includes(queryLower)) {
                score += 7; // Tag matches are very relevant
            }
            if (categoriesLower.includes(queryLower)) {
                score += 6; // Category matches are relevant
            }
            if (contentLower.includes(queryLower)) {
                score += 2; // Content matches are less important
            }

            if (score > 0) {
                results.push({
                    ...item,
                    score: score
                });
            }
        });

        // Sort by score (highest first)
        results.sort((a, b) => b.score - a.score);

        // Display results
        displayResults(results, query);
    }

    // Display search results
    function displayResults(results, query) {
        if (results.length === 0) {
            searchResults.innerHTML = `
                <div class="search-no-results">
                    <i class="fas fa-search"></i>
                    <p>No results found for "<strong>${escapeHtml(query)}</strong>"</p>
                    <p class="search-hint">Try different keywords or check your spelling</p>
                </div>
            `;
            return;
        }

        let html = `<p class="search-count">Found ${results.length} result${results.length !== 1 ? 's' : ''} for "<strong>${escapeHtml(query)}</strong>"</p>`;
        html += '<div class="search-results-list">';

        results.forEach(result => {
            const typeIcon = result.type === 'post' ? 'fa-file-alt' : 'fa-folder';
            const typeLabel = result.type === 'post' ? 'Blog Post' : 'Project';
            const dateDisplay = result.date ? `<span class="result-date"><i class="far fa-calendar"></i> ${result.date}</span>` : '';
            const tagsDisplay = result.tags && result.tags.length > 0 ?
                `<div class="result-tags">${result.tags.map(tag => `<span class="result-tag">${escapeHtml(tag)}</span>`).join('')}</div>` : '';

            html += `
                <div class="search-result-card">
                    <div class="result-header">
                        <span class="result-type"><i class="fas ${typeIcon}"></i> ${typeLabel}</span>
                        ${dateDisplay}
                    </div>
                    <h3 class="result-title">
                        <a href="${result.url}">${escapeHtml(result.title)}</a>
                    </h3>
                    <p class="result-excerpt">${escapeHtml(result.excerpt)}</p>
                    ${tagsDisplay}
                </div>
            `;
        });

        html += '</div>';
        searchResults.innerHTML = html;
    }

    // Escape HTML to prevent XSS
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Event listeners
    searchButton.addEventListener('click', async function() {
        await loadSearchIndex();
        performSearch(searchInput.value);
    });

    searchInput.addEventListener('keypress', async function(event) {
        if (event.key === 'Enter') {
            await loadSearchIndex();
            performSearch(searchInput.value);
        }
    });

    // Real-time search (optional, searches as you type after 500ms delay)
    let searchTimeout;
    searchInput.addEventListener('input', async function() {
        clearTimeout(searchTimeout);

        if (searchInput.value.trim().length === 0) {
            searchResults.innerHTML = '<p class="search-instructions">Enter a search term to find blog posts and projects.</p>';
            return;
        }

        searchTimeout = setTimeout(async () => {
            await loadSearchIndex();
            performSearch(searchInput.value);
        }, 500); // Wait 500ms after user stops typing
    });

    // Load search index on page load for faster first search
    loadSearchIndex();
});

// Blog page search functionality
document.addEventListener('DOMContentLoaded', function() {
    const blogSearchInput = document.getElementById('blog-search-input');
    const blogSearchClear = document.getElementById('blog-search-clear');
    const filterButtons = document.querySelectorAll('.filter-btn');
    const paginatedContainer = document.querySelector('.blog-posts-paginated');
    const allPostsContainer = document.querySelector('.blog-posts-all');
    const paginationControls = document.querySelector('.pagination');
    const paginationInfo = document.querySelector('.pagination-info');

    if (!blogSearchInput) {
        return; // Not on blog page
    }

    let currentSearchQuery = '';
    let currentCategoryFilter = 'all';

    // Function to filter posts by search and category
    function filterPosts() {
        const query = currentSearchQuery.toLowerCase().trim();
        const category = currentCategoryFilter;
        let visibleCount = 0;

        // Remove any existing no-results message
        const existingNoResults = document.querySelector('.no-filter-results');
        if (existingNoResults) {
            existingNoResults.remove();
        }

        // If no search query and showing all categories, return to pagination
        if (query === '' && category === 'all') {
            if (paginatedContainer) paginatedContainer.style.display = 'grid';
            if (allPostsContainer) allPostsContainer.style.display = 'none';
            if (paginationControls) paginationControls.style.display = 'flex';
            if (paginationInfo) paginationInfo.style.display = 'block';
            return;
        }

        // Show all posts container for filtering
        if (paginatedContainer) paginatedContainer.style.display = 'none';
        if (allPostsContainer) allPostsContainer.style.display = 'grid';
        if (paginationControls) paginationControls.style.display = 'none';
        if (paginationInfo) paginationInfo.style.display = 'none';

        // Filter posts
        const allPosts = allPostsContainer.querySelectorAll('.blog-post-card');
        allPosts.forEach(post => {
            let matchesSearch = true;
            let matchesCategory = true;

            // Check category filter
            if (category !== 'all') {
                const postCategories = post.getAttribute('data-categories');
                matchesCategory = postCategories && postCategories.includes(category);
            }

            // Check search query
            if (query !== '') {
                const title = post.querySelector('.post-card-title')?.textContent.toLowerCase() || '';
                const excerpt = post.querySelector('.post-card-excerpt')?.textContent.toLowerCase() || '';
                const tags = Array.from(post.querySelectorAll('.tag')).map(tag => tag.textContent.toLowerCase()).join(' ');
                const categories = post.getAttribute('data-categories')?.toLowerCase() || '';

                matchesSearch = title.includes(query) ||
                               excerpt.includes(query) ||
                               tags.includes(query) ||
                               categories.includes(query);
            }

            // Show or hide post based on both filters
            if (matchesSearch && matchesCategory) {
                post.style.display = 'block';
                post.style.animation = 'fadeInUp 0.5s ease';
                visibleCount++;
            } else {
                post.style.display = 'none';
            }
        });

        // Show message if no posts match filters
        if (visibleCount === 0) {
            const message = document.createElement('div');
            message.className = 'no-filter-results';
            let messageText = 'No posts found';
            if (query !== '' && category !== 'all') {
                messageText += ` matching "${query}" in this category.`;
            } else if (query !== '') {
                messageText += ` matching "${query}".`;
            } else {
                messageText += ' in this category.';
            }
            message.innerHTML = `<i class="fas fa-search"></i><p>${messageText}</p>`;
            allPostsContainer.appendChild(message);
        }
    }

    // Search input handler
    let searchTimeout;
    blogSearchInput.addEventListener('input', function() {
        clearTimeout(searchTimeout);
        currentSearchQuery = this.value;

        // Show/hide clear button
        if (currentSearchQuery.trim().length > 0) {
            blogSearchClear.style.display = 'flex';
        } else {
            blogSearchClear.style.display = 'none';
        }

        // Debounce search
        searchTimeout = setTimeout(() => {
            filterPosts();
        }, 300); // Wait 300ms after user stops typing
    });

    // Clear button handler
    blogSearchClear.addEventListener('click', function() {
        blogSearchInput.value = '';
        currentSearchQuery = '';
        this.style.display = 'none';
        blogSearchInput.focus();
        filterPosts();
    });

    // Category filter button handler (integrate with existing functionality)
    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            currentCategoryFilter = this.getAttribute('data-filter');
            filterPosts();
        });
    });
});

// Hero background slideshow with parallax effect
document.addEventListener('DOMContentLoaded', function() {
    const heroSection = document.querySelector('.hero');

    if (!heroSection) {
        return; // Not on a page with a hero section
    }

    const backgroundLayers = heroSection.querySelectorAll('.hero-background');

    if (backgroundLayers.length === 0) {
        return; // No background layers found
    }

    let currentBackgroundIndex = 0;
    let ticking = false;

    // Background slideshow with blend transitions
    function rotateBackground() {
        // Remove active class from current background
        backgroundLayers[currentBackgroundIndex].classList.remove('active');

        // Move to next background (loop back to start if at end)
        currentBackgroundIndex = (currentBackgroundIndex + 1) % backgroundLayers.length;

        // Add active class to new background (triggers fade in via CSS transition)
        backgroundLayers[currentBackgroundIndex].classList.add('active');
    }

    // Start slideshow - change background every 8 seconds
    const slideshowInterval = setInterval(rotateBackground, 8000);

    // Enhanced parallax scrolling effect for all background layers
    // Adjusts background position based on scroll for smoother parallax
    function updateParallax() {
        const scrollPosition = window.pageYOffset;
        const heroHeight = heroSection.offsetHeight;

        // Only apply parallax while hero is visible
        if (scrollPosition <= heroHeight) {
            // Move background at 50% of scroll speed for parallax effect
            const yPos = scrollPosition * 0.5;

            // Apply parallax to all background layers
            backgroundLayers.forEach(layer => {
                layer.style.backgroundPosition = `center ${yPos}px`;
            });
        }

        ticking = false;
    }

    // Throttle scroll events for performance using requestAnimationFrame
    function requestParallaxUpdate() {
        if (!ticking) {
            requestAnimationFrame(updateParallax);
            ticking = true;
        }
    }

    // Listen for scroll events
    window.addEventListener('scroll', requestParallaxUpdate);

    // Initial parallax call
    updateParallax();

    // Cleanup: Stop slideshow when page is hidden (performance optimization)
    document.addEventListener('visibilitychange', function() {
        if (document.hidden) {
            clearInterval(slideshowInterval);
        }
    });
});
