// Modern browsers support WebP natively
// This site serves only WebP images for optimal performance

// Lazy Loading Fallback for Older Browsers
// Modern browsers support native lazy loading (loading="lazy" attribute)
// This provides fallback for browsers without native support using Intersection Observer
document.addEventListener('DOMContentLoaded', function() {
    // Check if browser supports native lazy loading
    if ('loading' in HTMLImageElement.prototype) {
        // Native lazy loading is supported, no need for polyfill
        return;
    }

    // Fallback for older browsers using Intersection Observer
    const lazyImages = document.querySelectorAll('img[loading="lazy"]');

    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver(function(entries, observer) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    const picture = img.parentElement;

                    // Handle picture element with multiple sources
                    if (picture && picture.tagName === 'PICTURE') {
                        const sources = picture.querySelectorAll('source');
                        sources.forEach(function(source) {
                            if (source.dataset.srcset) {
                                source.srcset = source.dataset.srcset;
                            }
                        });
                    }

                    // Load the image
                    if (img.dataset.src) {
                        img.src = img.dataset.src;
                    }

                    // Remove loading attribute and stop observing
                    img.removeAttribute('loading');
                    imageObserver.unobserve(img);
                }
            });
        }, {
            rootMargin: '50px 0px', // Start loading 50px before image enters viewport
            threshold: 0.01
        });

        lazyImages.forEach(function(img) {
            imageObserver.observe(img);
        });
    } else {
        // No Intersection Observer support - load all images immediately
        lazyImages.forEach(function(img) {
            if (img.dataset.src) {
                img.src = img.dataset.src;
            }
        });
    }
});

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
    const codeBlocks = document.querySelectorAll('.post-content pre, .help-file-display pre');

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

// Syntax highlighting for PowerShell help file
document.addEventListener('DOMContentLoaded', function() {
    const helpFileCode = document.querySelector('.help-file-display code');

    if (helpFileCode) {
        let content = helpFileCode.textContent;

        // Highlight section headers (all caps words at start of line)
        content = content.replace(/^([A-Z][A-Z\s&]+)$/gm, '<span class="help-header">$1</span>');

        // Highlight URLs
        content = content.replace(/(https?:\/\/[^\s]+)/g, '<span class="help-url">$1</span>');

        // Highlight PowerShell cmdlets (Get-, Set-, etc.)
        content = content.replace(/\b(Get|Set|New|Remove|Add|Update|Install|Import|Export|Invoke|Test|Start|Stop|Enable|Disable|Write|Read|Copy|Move)-[\w]+\b/g, '<span class="help-cmdlet">$1</span>');

        // Highlight comments in code examples (lines starting with #)
        content = content.replace(/^(\s*)(#.*)$/gm, '$1<span class="help-comment">$2</span>');

        // Highlight strings in double quotes
        content = content.replace(/"([^"]+)"/g, '<span class="help-string">"$1"</span>');

        // Highlight variables (words starting with $)
        content = content.replace(/(\$[\w]+)/g, '<span class="help-variable">$1</span>');

        // Highlight operators
        content = content.replace(/\s(-eq|-ne|-gt|-lt|-ge|-le|-like|-notlike|-match|-notmatch|-contains|-notcontains|-in|-notin|=|->)\s/g, ' <span class="help-operator">$1</span> ');

        helpFileCode.innerHTML = content;
    }
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
                    <div class="result-excerpt">${sanitizeHtml(result.excerpt)}</div>
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

    // Sanitize HTML to allow safe formatting tags
    function sanitizeHtml(html) {
        if (!html) return '';

        // Create a temporary div to parse HTML
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = html;

        // Define allowed tags and their allowed attributes
        const allowedTags = ['p', 'br', 'strong', 'b', 'em', 'i', 'u', 'ul', 'ol', 'li', 'span'];
        const allowedAttributes = []; // No attributes allowed for security

        // Recursive function to sanitize nodes
        function sanitizeNode(node) {
            // If it's a text node, return it as-is
            if (node.nodeType === Node.TEXT_NODE) {
                return document.createTextNode(node.textContent);
            }

            // If it's an element node
            if (node.nodeType === Node.ELEMENT_NODE) {
                const tagName = node.tagName.toLowerCase();

                // If tag is not allowed, return its text content only
                if (!allowedTags.includes(tagName)) {
                    return document.createTextNode(node.textContent);
                }

                // Create a new clean element
                const cleanElement = document.createElement(tagName);

                // Recursively sanitize and append child nodes
                Array.from(node.childNodes).forEach(child => {
                    const sanitizedChild = sanitizeNode(child);
                    if (sanitizedChild) {
                        cleanElement.appendChild(sanitizedChild);
                    }
                });

                return cleanElement;
            }

            return null;
        }

        // Create a new div for the sanitized content
        const cleanDiv = document.createElement('div');
        Array.from(tempDiv.childNodes).forEach(child => {
            const sanitizedChild = sanitizeNode(child);
            if (sanitizedChild) {
                cleanDiv.appendChild(sanitizedChild);
            }
        });

        return cleanDiv.innerHTML;
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

    // Check for query parameter in URL
    const urlParams = new URLSearchParams(window.location.search);
    const queryParam = urlParams.get('q');

    if (queryParam && queryParam.trim().length > 0) {
        searchInput.value = queryParam;
        // Automatically perform search when page loads with query parameter
        (async function() {
            await loadSearchIndex();
            performSearch(queryParam);
        })();
    } else {
        // Load search index on page load for faster first search
        loadSearchIndex();
    }
});

// Blog page search functionality
document.addEventListener('DOMContentLoaded', function() {
    const blogSearchInput = document.getElementById('blog-search-input');
    const blogSearchClear = document.getElementById('blog-search-clear');
    const advancedFilterToggle = document.getElementById('advanced-filter-toggle');
    const advancedFiltersPanel = document.getElementById('advanced-filters');
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

    // Advanced filters toggle
    if (advancedFilterToggle && advancedFiltersPanel) {
        advancedFilterToggle.addEventListener('click', function() {
            const isExpanded = this.getAttribute('aria-expanded') === 'true';

            if (isExpanded) {
                // Collapse
                advancedFiltersPanel.style.display = 'none';
                this.setAttribute('aria-expanded', 'false');
                this.querySelector('.toggle-text').textContent = 'Filters';
            } else {
                // Expand
                advancedFiltersPanel.style.display = 'block';
                this.setAttribute('aria-expanded', 'true');
                this.querySelector('.toggle-text').textContent = 'Filters';
            }
        });
    }

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

    // Handle URL hash filter (e.g., /blog#filter=automation)
    function applyHashFilter() {
        const hash = window.location.hash;
        if (hash && hash.startsWith('#filter=')) {
            const filterValue = hash.replace('#filter=', '');

            // Find and click the corresponding filter button
            const matchingButton = Array.from(filterButtons).find(btn =>
                btn.getAttribute('data-filter') === filterValue
            );

            if (matchingButton) {
                // Update active button state
                filterButtons.forEach(btn => btn.classList.remove('active'));
                matchingButton.classList.add('active');

                // Apply the filter
                currentCategoryFilter = filterValue;
                filterPosts();

                // Scroll to blog content after a short delay
                setTimeout(() => {
                    const blogSection = document.querySelector('.blog-section');
                    if (blogSection) {
                        const offset = 100; // Offset for fixed header
                        const elementPosition = blogSection.getBoundingClientRect().top;
                        const offsetPosition = elementPosition + window.pageYOffset - offset;

                        window.scrollTo({
                            top: offsetPosition,
                            behavior: 'smooth'
                        });
                    }
                }, 100);
            }
        }
    }

    // Apply hash filter on page load
    applyHashFilter();

    // Apply hash filter when hash changes (for single-page navigation)
    window.addEventListener('hashchange', applyHashFilter);
});

// Hero background slideshow with parallax effect
document.addEventListener('DOMContentLoaded', function() {
    // Find all sections with hero backgrounds
    const sectionsWithBackgrounds = document.querySelectorAll('.hero, .recent-posts');

    if (sectionsWithBackgrounds.length === 0) {
        return; // No sections with backgrounds found
    }

    const slideshowIntervals = [];

    // Initialize backgrounds for each section
    sectionsWithBackgrounds.forEach(function(section) {
        const backgroundLayers = section.querySelectorAll('.hero-background');

        if (backgroundLayers.length === 0) {
            return; // No background layers in this section
        }

        // Load background images
        backgroundLayers.forEach(function(layer) {
            const imageSrc = layer.dataset.bg;
            if (imageSrc) {
                layer.style.backgroundImage = 'url(' + imageSrc + ')';
            }
        });

        // Start with a random background image
        let currentBackgroundIndex = Math.floor(Math.random() * backgroundLayers.length);

        // Set the initial random background as active
        backgroundLayers.forEach((layer, index) => {
            if (index === currentBackgroundIndex) {
                layer.classList.add('active');
            } else {
                layer.classList.remove('active');
            }
        });

        // Background slideshow with blend transitions
        function rotateBackground() {
            // Remove active class from current background
            backgroundLayers[currentBackgroundIndex].classList.remove('active');

            // Move to next background (loop back to start if at end)
            currentBackgroundIndex = (currentBackgroundIndex + 1) % backgroundLayers.length;

            // Add active class to new background (triggers fade in via CSS transition)
            backgroundLayers[currentBackgroundIndex].classList.add('active');
        }

        // Start slideshow - change background every 16 seconds
        const slideshowInterval = setInterval(rotateBackground, 16000);
        slideshowIntervals.push(slideshowInterval);
    });

    // Enhanced parallax scrolling effect for all background layers
    let ticking = false;

    function updateParallax() {
        const scrollPosition = window.pageYOffset;

        sectionsWithBackgrounds.forEach(function(section) {
            const backgroundLayers = section.querySelectorAll('.hero-background');
            const sectionTop = section.offsetTop;
            const sectionHeight = section.offsetHeight;

            // Only apply parallax while section is in viewport
            if (scrollPosition + window.innerHeight > sectionTop && scrollPosition < sectionTop + sectionHeight) {
                // Move background upward at 50% of scroll speed for parallax effect
                // Negative values move background up, revealing top of zoomed image as user scrolls down
                const sectionScrollPosition = scrollPosition - sectionTop;
                const yPos = -(sectionScrollPosition * 0.5);

                // Apply parallax to all background layers in this section
                backgroundLayers.forEach(layer => {
                    layer.style.backgroundPosition = `center calc(100% + ${yPos}px)`;
                });
            }
        });

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

    // Cleanup: Stop slideshows when page is hidden (performance optimization)
    document.addEventListener('visibilitychange', function() {
        if (document.hidden) {
            slideshowIntervals.forEach(interval => clearInterval(interval));
        }
    });
});

// Back to Top button functionality
document.addEventListener('DOMContentLoaded', function() {
    const backToTopButton = document.getElementById('backToTopButton');

    if (!backToTopButton) {
        return; // Back to top button not found
    }

    // Show button when user scrolls down 300px from the top
    function checkScrollPosition() {
        if (window.pageYOffset > 300) {
            backToTopButton.classList.add('visible');
        } else {
            backToTopButton.classList.remove('visible');
        }
    }

    // Scroll to top smoothly when button is clicked
    backToTopButton.addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });

    // Check scroll position on scroll event
    let scrollTimeout;
    window.addEventListener('scroll', function() {
        // Debounce scroll events for better performance
        if (scrollTimeout) {
            clearTimeout(scrollTimeout);
        }
        scrollTimeout = setTimeout(checkScrollPosition, 50);
    });

    // Initial check
    checkScrollPosition();
});

// Navigation search functionality
document.addEventListener('DOMContentLoaded', function() {
    const navSearchInput = document.getElementById('nav-search-input');
    const navSearchSubmit = document.querySelector('.nav-search-submit');
    const navSearchIcon = document.querySelector('.nav-search-icon');

    if (navSearchInput && navSearchSubmit) {
        // Handle search submission
        function performNavSearch() {
            const query = navSearchInput.value.trim();
            if (query.length > 0) {
                // Navigate to search page with query parameter
                window.location.href = `/search?q=${encodeURIComponent(query)}`;
            }
        }

        // Submit on button click
        navSearchSubmit.addEventListener('click', performNavSearch);

        // Submit on Enter key
        navSearchInput.addEventListener('keypress', function(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                performNavSearch();
            }
        });

        // Focus input when icon is clicked
        if (navSearchIcon) {
            navSearchIcon.addEventListener('click', function() {
                navSearchInput.focus();
            });
        }
    }
});

// Features Carousel - Shows 3-4 cards with infinite loop (no cloning)
document.addEventListener('DOMContentLoaded', function() {
    const carouselContainers = document.querySelectorAll('.features-carousel');

    if (carouselContainers.length === 0) {
        return; // Not on a page with carousel
    }

    // Initialize each carousel independently
    carouselContainers.forEach(function(carouselContainer) {
        const track = carouselContainer.querySelector('.features-carousel-track');
        const cards = Array.from(track.querySelectorAll('.feature-card'));
        const indicatorsContainer = carouselContainer.querySelector('.carousel-indicators');

        if (cards.length === 0) {
            return;
        }

        const totalCards = cards.length;
        let currentIndex = 0;
        let direction = 1; // 1 for forward, -1 for backward
        let pausedAtBoundary = false; // Track if we just paused at a boundary
        let autoPlayInterval;
        const transitionDuration = 1200; // 1.2 seconds for smoother animation
        const autoPlayDelay = 12000; // 12 seconds between slides

        // Get number of cards visible at current viewport size
        function getVisibleCardCount() {
            const containerWidth = carouselContainer.offsetWidth;
            const isBlogPostsCarousel = carouselContainer.closest('.recent-posts') !== null;

            // Blog posts carousel: 3 cards on desktop
            // Features carousel: 4 cards on desktop
            // Both: 2 cards on tablet, 1 card on mobile
            if (containerWidth > 900) {
                return isBlogPostsCarousel ? 3 : 4;
            }
            if (containerWidth > 600) return 2;
            return 1;
        }

    // Create indicator dots
    function createIndicators() {
        indicatorsContainer.innerHTML = '';

        for (let i = 0; i < totalCards; i++) {
            const indicator = document.createElement('button');
            indicator.classList.add('carousel-indicator');
            indicator.setAttribute('aria-label', `Go to slide ${i + 1}`);

            indicator.addEventListener('click', function() {
                goToSlide(i);
                resetAutoPlay();
            });

            indicatorsContainer.appendChild(indicator);
        }

        updateIndicators();
    }

    // Update indicator active state
    function updateIndicators() {
        const indicators = indicatorsContainer.querySelectorAll('.carousel-indicator');

        indicators.forEach((indicator, index) => {
            indicator.classList.toggle('active', index === currentIndex);
        });
    }

    // Update carousel position
    function updateCarouselPosition(animated = true) {
        const firstCard = cards[0];
        if (!firstCard) return;

        const cardWidth = firstCard.offsetWidth;
        const gap = parseInt(getComputedStyle(track).gap) || 32;
        const cardStep = cardWidth + gap;
        const offset = -(currentIndex * cardStep);

        if (!animated) {
            track.style.transition = 'none';
        } else {
            track.style.transition = '';
        }

        track.style.transform = `translateX(${offset}px)`;

        if (!animated) {
            track.offsetHeight; // Force reflow
        }

        updateIndicators();
    }

    // Go to specific slide
    function goToSlide(index) {
        const visibleCards = getVisibleCardCount();
        const maxIndex = totalCards - visibleCards;

        // Don't go past the point where we can't fill the viewport
        currentIndex = Math.min(index, maxIndex);
        updateCarouselPosition(true);
    }

    // Advance to next slide (respects direction)
    function nextSlide() {
        const visibleCards = getVisibleCardCount();
        const maxIndex = totalCards - visibleCards;

        // If we're at a boundary and already paused, reverse direction
        if (pausedAtBoundary) {
            if (currentIndex >= maxIndex) {
                direction = -1; // Reverse to backward
            } else if (currentIndex <= 0) {
                direction = 1; // Reverse to forward
            }
            pausedAtBoundary = false;
        }

        // Move in current direction
        currentIndex += direction;

        // Check if we hit a boundary and need to pause
        if (currentIndex >= maxIndex) {
            currentIndex = maxIndex;
            pausedAtBoundary = true; // Pause here for one cycle
        } else if (currentIndex <= 0) {
            currentIndex = 0;
            pausedAtBoundary = true; // Pause here for one cycle
        }

        updateCarouselPosition(true);
    }

    // Go to previous slide
    function previousSlide() {
        const visibleCards = getVisibleCardCount();
        const maxIndex = totalCards - visibleCards;

        if (currentIndex <= 0) {
            // At the beginning, jump to end
            currentIndex = maxIndex;
        } else {
            currentIndex--;
        }

        updateCarouselPosition(true);
    }

    // Start auto-play
    function startAutoPlay() {
        autoPlayInterval = setInterval(nextSlide, autoPlayDelay);
    }

    // Stop auto-play
    function stopAutoPlay() {
        clearInterval(autoPlayInterval);
    }

    // Reset auto-play
    function resetAutoPlay() {
        stopAutoPlay();
        startAutoPlay();
    }

    // Handle window resize
    let resizeTimeout;
    function handleResize() {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(() => {
            // Adjust position if needed after resize
            const visibleCards = getVisibleCardCount();
            const maxIndex = totalCards - visibleCards;
            if (currentIndex > maxIndex) {
                currentIndex = maxIndex;
            }
            updateCarouselPosition(false);
        }, 250);
    }

    // Initialize carousel
    function initCarousel() {
        createIndicators();
        updateCarouselPosition(false);
        startAutoPlay();

        // Pause on hover
        carouselContainer.addEventListener('mouseenter', stopAutoPlay);
        carouselContainer.addEventListener('mouseleave', startAutoPlay);

        // Handle window resize
        window.addEventListener('resize', handleResize);

        // Pause when page is not visible
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                stopAutoPlay();
            } else {
                startAutoPlay();
            }
        });
    }

        // Start the carousel
        initCarousel();
    }); // End forEach carousel
});
