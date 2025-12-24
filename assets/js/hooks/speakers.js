export const SpeakerScroll = {
  mounted() {
    this.currentSpeakerId = null;
    this.speakerItems = [];
    this.currentIndex = 0;
    this.isHovering = false;
    
    // Obter todos os speakers
    this.updateSpeakerItems = () => {
      this.speakerItems = Array.from(this.el.querySelectorAll(".speaker-item:not(.cloned)"));
    };
    
    // Calcular offset para scroll suave (centrar item)
    this.scrollToItem = (item) => {
      const containerHeight = this.el.clientHeight;
      const itemTop = item.offsetTop;
      const itemHeight = item.offsetHeight;
      const scrollTarget = itemTop - (containerHeight / 2) + (itemHeight / 2);
      
      this.el.scrollTo({
        top: scrollTarget,
        behavior: 'smooth'
      });
    };
    
    // Selecionar speaker por índice (com loop)
    this.selectSpeakerByIndex = (index) => {
      if (this.speakerItems.length === 0) return;
      
      // Loop infinito
      if (index < 0) {
        index = this.speakerItems.length - 1;
      } else if (index >= this.speakerItems.length) {
        index = 0;
      }
      
      this.currentIndex = index;
      const item = this.speakerItems[index];
      const speakerId = item.dataset.speakerId;
      
      if (speakerId && speakerId !== this.currentSpeakerId) {
        this.currentSpeakerId = speakerId;
        this.pushEvent("select_speaker", { id: speakerId });
      }
      
      // Scroll suave para centrar o item selecionado
      this.scrollToItem(item);
    };
    
    // Capturar scroll da roda do rato
    this.handleWheel = (e) => {
      if (!this.isHovering) return;
      
      e.preventDefault();
      e.stopPropagation();
      
      // Determinar direção do scroll
      if (e.deltaY > 0) {
        // Scroll para baixo - próximo speaker
        this.selectSpeakerByIndex(this.currentIndex + 1);
      } else if (e.deltaY < 0) {
        // Scroll para cima - speaker anterior
        this.selectSpeakerByIndex(this.currentIndex - 1);
      }
    };
    
    // Eventos de hover
    this.handleMouseEnter = () => {
      this.isHovering = true;
      // Prevenir scroll da página quando hover no container
      document.body.style.overflow = 'hidden';
    };
    
    this.handleMouseLeave = () => {
      this.isHovering = false;
      document.body.style.overflow = '';
    };
    
    // Inicializar
    setTimeout(() => {
      this.updateSpeakerItems();
      if (this.speakerItems.length > 0) {
        // Encontrar o índice do speaker já selecionado
        const selectedItem = this.el.querySelector(".speaker-item.text-white.font-bold");
        if (selectedItem) {
          const index = this.speakerItems.indexOf(selectedItem);
          if (index >= 0) {
            this.currentIndex = index;
            this.currentSpeakerId = selectedItem.dataset.speakerId;
          }
        }
      }
    }, 100);
    
    // Adicionar listeners
    this.el.addEventListener("wheel", this.handleWheel, { passive: false });
    this.el.addEventListener("mouseenter", this.handleMouseEnter);
    this.el.addEventListener("mouseleave", this.handleMouseLeave);
  },

  destroyed() {
    this.el.removeEventListener("wheel", this.handleWheel);
    this.el.removeEventListener("mouseenter", this.handleMouseEnter);
    this.el.removeEventListener("mouseleave", this.handleMouseLeave);
    document.body.style.overflow = '';
  }
};

export const FadeIn = {
  mounted() {
    this.el.style.opacity = "0";
    this.el.style.transform = "scale(0.95)";
    
    requestAnimationFrame(() => {
      this.el.style.transition = "all 0.4s ease-out";
      this.el.style.opacity = "1";
      this.el.style.transform = "scale(1)";
    });
  },

  updated() {
    this.el.style.opacity = "0";
    this.el.style.transform = "scale(0.95)";
    
    requestAnimationFrame(() => {
      this.el.style.opacity = "1";
      this.el.style.transform = "scale(1)";
    });
  }
};
